import React, { useState } from "react";
import Box from "@mui/material/Box";
import ExpandMoreIcon from "@mui/icons-material/ExpandMore";
import ChevronRightIcon from "@mui/icons-material/ChevronRight";
import { TreeView } from "@mui/x-tree-view/TreeView";
import { TreeItem } from "@mui/x-tree-view/TreeItem";
import axios from "axios";

const convertTrialSuccess = {
  0: "Not Success",
  1: "Success",
  //Not sure what to display for Null value
  null: "Null",
};
const FileSystemNavigator = ({ data }) => {
  const [selectedFile, setSelectedFile] = useState(null);
  const [previewData, setPreviewData] = useState([]);
  const [previewLoading, setPreviewLoading] = useState(false);
  const [showPreviewButton, setShowPreviewButton] = useState(false);

  const renderFile = (file, prevIdx, i) => (
    <TreeItem
      key={`${file.type}-${prevIdx}-${i}`}
      nodeId={`file-${file.type}-${prevIdx}-${i}`}
      label={`File: ${file.type}`}
      onClick={() => {
        handleFileSelection(file.location, file.type);
      }}
    />
  );
  const renderTrial = (trial, prevIdx, i) => (
    <TreeItem
      key={`${trial.success}-${prevIdx}-${i}`}
      nodeId={`trial-${trial.success}-${prevIdx}-${i}`}
      label={`Trial: ${convertTrialSuccess[trial.success]}`}
    >
      {trial.process_runs &&
        trial.process_runs.map((run, j) => (
          <TreeItem
            key={`${run.type}-${prevIdx}-${i}-${j}`}
            nodeId={`run-${run.type}-${prevIdx}-${i}-${j}`}
            label={`Run: ${run.type}`}
          >
            {run.file_artifacts &&
              run.file_artifacts.map((artifact, k) =>
                renderFile(artifact, prevIdx, `${i}-${j}-${k}`)
              )}
          </TreeItem>
        ))}
    </TreeItem>
  );

  const renderRevision = (revision, prevIdx, i) => {
    return (
      <TreeItem
        key={`${revision.id}-${prevIdx}-${i}`}
        nodeId={`revision-${revision.id}-${prevIdx}-${i}`}
        label={revision.name}
      >
        {revision.trials &&
          revision.trials.map((trial, j) =>
            renderTrial(trial, prevIdx + "-" + i, j)
          )}
        {revision.geometry_files?.length &&
          revision.geometry_files.map((file, j) =>
            renderFile(file, prevIdx + "-" + i, j)
          )}
      </TreeItem>
    );
  };

  const renderPart = (partId, part, i, customerId) => (
    <TreeItem
      key={`part-${partId}-${customerId}-${i}`}
      nodeId={`part-${partId}-${customerId}-${i}`}
      label={part.name}
    >
      {part.revisions &&
        Object.values(part.revisions).map((revision, j) =>
          renderRevision(revision, customerId + "-" + i, j)
        )}
    </TreeItem>
  );

  const handleFileSelection = (fileLocation, fileType) => {
    setSelectedFile(fileLocation);
    setShowPreviewButton(fileType !== "CAD");
    setPreviewData(false);
  };

  const handleFileDownload = async (filename) => {
    try {
      const response = await axios.get(`http://localhost:5000/download`, {
        responseType: "blob",
        params: { filename },
      });

      // Check if the response has 'data' property before accessing it
      if (response && response.data) {
        const link = document.createElement("a");
        link.href = window.URL.createObjectURL(new Blob([response.data]));
        link.download = selectedFile;
        link.click();
      } else {
        console.error("Error downloading file: Empty or undefined response");
      }
    } catch (error) {
      console.error(
        "Error downloading file:",
        error.response?.data || error.message
      );
    }
  };

  const handleFilePreview = async (filename) => {
    setPreviewLoading(true);
    try {
      const response = await axios.get(`http://localhost:5000/preview`, {
        // responseType: 'blob',
        params: { filename },
      });

      // Check if the response has 'data' property before accessing it
      if (response && response.data) {
        setPreviewData(response.data);
      } else {
        console.error("Error previewing file: Empty or undefined response");
      }
      setPreviewLoading(false);
    } catch (error) {
      setPreviewLoading(false);
      console.error(
        "Error previewing file:",
        error.response?.data || error.message
      );
    }
  };

  // Sort customer keys alphabetically based on customer names
  const sortedCustomerKeys = Object.keys(data).sort((a, b) =>
    data[a].name.localeCompare(data[b].name)
  );

  return (
    <Box>
      <TreeView
        aria-label="file system navigator"
        defaultCollapseIcon={<ExpandMoreIcon />}
        defaultExpandIcon={<ChevronRightIcon />}
      >
        {sortedCustomerKeys.map((customerId) => (
          <TreeItem
            key={`customer-${customerId}`}
            nodeId={`customer-${customerId}`}
            label={data[customerId].name}
          >
            {data[customerId].parts &&
              Object.keys(data[customerId].parts).map((partId, i) =>
                renderPart(
                  partId,
                  data[customerId].parts[partId],
                  i,
                  customerId
                )
              )}
          </TreeItem>
        ))}
      </TreeView>
      {selectedFile && (
        <>
          <div>
            <p>Selected File: {selectedFile}</p>
            <button onClick={() => handleFileDownload(selectedFile)}>
              Download File
            </button>
          </div>
          {showPreviewButton && (
            <Box sx={{ marginTop: "5px" }}>
              <button
                disabled={previewLoading}
                onClick={() => handleFilePreview(selectedFile)}
              >
                File Preview
              </button>
            </Box>
          )}
        </>
      )}
      {!!previewData.length && (
        <Box sx={{ marginTop: "40px" }}>
          {previewData.map((row, i) => (
            <Box key={i} sx={{ marginBottom: "5px" }}>{row.join(", ")}</Box>
          ))}
        </Box>
      )}
      {previewLoading && <Box sx={{ marginTop: "40px" }}>Loading...</Box>}
    </Box>
  );
};

export default FileSystemNavigator;
