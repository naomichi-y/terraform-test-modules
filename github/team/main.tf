locals {
  team_memberships = flatten([for team, memberships in var.team_memberships :
    [for id, data in memberships : {
      id       = id
      team     = team
      username = data.username
      role     = lookup(data, "role", "member")
    }]
  ])
}

resource "github_team" "this" {
  name    = var.name
  privacy = "closed"
}

resource "github_team_membership" "this" {
  for_each = {
    for membership in local.team_memberships : membership.id => {
      team     = membership.team
      username = membership.username
      role     = membership.role
    }
  }

  team_id  = github_team.this[each.value.team].id
  username = each.value.username
  role     = each.value.role
}
