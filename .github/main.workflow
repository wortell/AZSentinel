workflow "New workflow" {
  on = "push"
  resolves = ["Run build]
}

action "Run Build" {
  uses = "./.github/build"
  secrets = ["GithubKey", "NuGetApiKey"]
  env = {}
}
