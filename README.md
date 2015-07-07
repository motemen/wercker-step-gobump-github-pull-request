gobump-github-pull-request
==========================

A wercker step to bump up your Go project's version using [gobump](https://github.com/motemen/gobump).

This step looks the latest commit and if it was a merge of pull requests, bumps the version value of the source code and pushes to master branch.

Configuration
-------------

- `github_token`
  - *Required*. A valid GitHub API token.
