package kubernetes.admission

import data.kubernetes.rolebindings

operations = {"CREATE","UPDATE"}

deny[msg] {
  input.request.kind.kind == "Droplet"
  is_space_developer
  forbidden_change
  msg = "Space developers can only change labels and annotations on Droplets"
}

is_space_developer = true {
    some rolebinding, subject
    rolebindings[rolebinding].subjects[subject].kind == "User"
    rolebindings[rolebinding].subjects[subject].name == input.request.userInfo.username
    rolebindings[rolebinding].roleRef.name == "space-developer"
}

is_space_developer = true {
    some rolebinding, subject, userGroup
    rolebindings[rolebinding].subjects[subject].kind == "Group"
    rolebindings[rolebinding].subjects[subject].name == input.request.userInfo.groups[userGroup]
    rolebindings[rolebinding].roleRef.name == "space-developer"
}

forbidden_change = true {
  objBody = json.remove(input.request.object, ["metadata/annotations", "metadata/labels", "metadata/managedFields"])
  oldObjBody = json.remove(input.request.oldObject, ["metadata/annotations", "metadata/labels", "metadata/managedFields"])
  objBody != oldObjBody
}
