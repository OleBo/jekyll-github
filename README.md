# jekyll-github

Jekyll plugin for Github

[![Gem Version](https://badge.fury.io/rb/jekyll-github.svg)](https://badge.fury.io/rb/jekyll-github)

## Installing

1. Add `jekyll-github` to your Gemfile:
    ```
    gem 'jekyll-github'
    ```

2. Add the following to your site's `_config.yml`:
    ```yml
    plugins:
        - jekyll-github
    ```

## How to use it?

* You can add github links simply by adding the string `gh@`.

* You can add the following in your markdown:
    * **mention:** `gh@vrongmeal`

        This gives the result [@vrongmeal](https://github.com/vrongmeal)

    * **repository:** `gh@vrongmeal/readit`
    * **repository at a branch:** `gh@vrongmeal/dayts:gh-pages`
    * **issue or a pull request:** `gh@vrongmeal/dayts#2`
    * **file or directory:** `gh@vrongmeal/dayts/src/index.js`
    * **file or directory at a branch:** `gh@vrongmeal/dayts:gh-pages/bundle.js`
    * **tag (releases):** `gh@vrongmeal/zulip=1.8.1`

* As you might see, there are certain components in every command type. The following are all the components:
    * `user` as in mention
    * `repo` as in repository
    * `branch` as in repository at a branch
    * `issue_pr` in issue or pull request
    * `file` path of file or file at a branch
    * `tag` as in tag (releases)
    * `link` for github link (valid for all)

Let's configure the plugin.

## Configuration

You can configure the plugin either globally (in `_config.yml`) or in particular page (at the top of page between the two `---`). The settings in the page will take preference.

The configuration is for defining the format string for the output of type of commands. Let's see through an example:

```yml
jekyll-github:
    mention: '@<user>'
    repo: '<user>/<repo>'
    repo_branch: '<user>/<repo>:<branch>'
    issue_pr: '#<issue_pr>'
    file: '<repo>/<file>'
    file_branch: '<repo>:<branch>/<file>'
    tag: '<repo>=<tag>'
```

This above is the default configuration of the plugin. Let's cutomize it by saying we need complete link for a github file on a page. Simply, we can add the following setting on the top of the page:

```yml
jekyll-github:
    file: '<link>'
```

## Summary

| Link to | Setting key | Markdown syntax |
| --- | --- | --- |
| mention | `mention` | `gh@<user>` |
| repository | `repo` | `gh@<user>/<repo>` |
| repository at a branch | `repo_branch` | `gh@<user>/<repo>:<branch>` |
| issue or a pull request | `issue_pr` | `gh@<user>/<repo>#<issue_pr>` |
| file | `file` | `gh@<user>/<repo>/<file>` |
| file at a branch | `file_branch` | `gh@<user>/<repo>:<branch>/<file>` |
| tag (releases) | `tag` | `gh@<user>/<repo>=<tag>` |

And now you have the power of github in your jekyll site!
