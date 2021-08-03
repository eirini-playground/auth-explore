package kubernetes.admission

import data.kubernetes.rolebindings

operations = {"CREATE","UPDATE"}

deny[msg] {
  input.request.kind.kind == "Droplet"
  objBody = json.remove(input.request.object, ["metadata/annotations", "metadata/labels", "metadata/managedFields"])
  oldObjBody = json.remove(input.request.oldObject, ["metadata/annotations", "metadata/labels", "metadata/managedFields"])
  objBody != oldObjBody
  msg = sprintf("objBody: %q, oldObjBody: %q", [objBody, oldObjBody])
}
