resource "aws_iam_group" "education" {
  name = "Education"
  path = "/groups/"
}

resource "aws_iam_group" "engineers" {
  name = "Engineering"
  path = "/groups/"
}

resource "aws_iam_group" "managers" {
  name = "HR"
  path = "/groups/"
}

resource "aws_iam_group_membership" "education_members" {
  name = "EducationGroupMembership"
  users = [for user in aws_iam_user.users : user.name if user.tags["Department"] == "Education"]
  group = aws_iam_group.education.name
}


resource "aws_iam_group_membership" "engineering_members" {
  name = "EngineeringGroupMembership"
  users = [for user in aws_iam_user.users : user.name if user.tags["Department"] == "Engineering"]
  group = aws_iam_group.engineers.name
}

resource "aws_iam_group_membership" "managers_members" {
  name = "HRGroupMembership"
  users = [for user in aws_iam_user.users : user.name if contains(keys(user.tags),"JobTitle") && can(regex("Manager|CEO",user.tags.JobTitle))]
  group = aws_iam_group.managers.name
}