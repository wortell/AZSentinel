workflow "New workflow" {
  on = "push"
  resolves = ["Run Build"]
}

action "Run Build" {
  uses = "./.github/build"
  secrets = ["GithubKey","NuGetApiKey"]
}
