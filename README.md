gobump-github-pull-request
==========================

A wercker step to bump up your Go project's version using [gobump](https://github.com/motemen/gobump).

This step looks the latest commit and if it was a merge of pull requests, bumps the version value of the source code and pushes to master branch.

Configuration
-------------

- `github_token`
  - *Required*. A valid GitHub API token.
- `label_pattern_major`
  - Pull requests with labels matching this pattern (in "extended regular expression") will bump the "major" part.
  - Defaults to no pattern.
- `label_pattern_minor`
  - Ditto for "minor" part.
- `changed_files_pattern`
  - Pull requests containing changes matching this pattern (in "extended regular expression") will cause version bump.
  - Defaults to `\.go$`.
