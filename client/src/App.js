import React, { useState, useEffect } from "react";
import FileSystemNavigator from "./fileSystemNavigator.js";
import axios from "axios";

function App() {
  const [data, setData] = useState([]);

  useEffect(() => {
    axios.get("/file_tree")
      .then((response) => {
        setData(response.data);
      });
  }, []);
  return <FileSystemNavigator data={data} />;
}

export default App;
