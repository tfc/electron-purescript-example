import { contextBridge } from "electron"

contextBridge.exposeInMainWorld("electronAPI", {
  foo: "bar"
})
