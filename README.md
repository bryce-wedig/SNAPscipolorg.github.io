# Scientist Network for Advancing Policy (SNAP) Coalition Website

This public repository contains the source code for the SNAP Coalition's website.

## About SNAP

The [Scientist Network for Advancing Policy (SNAP) Coalition](https://snapcoalition.org/) is an international group of early-career scientists dedicated to mobilizing for large-scale initiatives and building capacity to bridge gaps between science and society. Our mission is to inspire and engage fellow scientists by establishing a peer network, developing and sharing resources, and instigating meaningful change.

## Repo Information

![GitHub contributors](https://img.shields.io/github/contributors/SNAPscipolorg/SNAPscipolorg.github.io?style=for-the-badge)

![GitHub last commit](https://img.shields.io/github/last-commit/SNAPscipolorg/SNAPscipolorg.github.io?style=for-the-badge)

![License](https://img.shields.io/github/license/SNAPscipolorg/SNAPscipolorg.github.io?style=for-the-badge)

This website uses the [Academic Website Template](https://github.com/sbryngelson/academic-website-template).

## For Developers

### Building the website locally

To build locally, [install Jekyll](https://jekyllrb.com/docs/installation/) then run `bundle exec jekyll serve` to serve at `localhost:4000`. 

On macOS (with default zsh shell) for chruby installed via Homebrew, the bash script `deploy.sh` in the root directory will load chruby and serve the website locally. The first few steps are unnecessary if you've added the chruby commands to your `~/.zshrc`.

### Adding a team member

1. Create a new item in `_data/members.yml`. Note that we list team members alphabetically by first name, and for `instagram`, `twitter`, and `linkedin`, only the handle is necessary.
2. Put their photo in `images/teamheadshots/`

### Adding a member organization

1. Create a new item in `_data/member_orgs.yml`. Note that we list organizations alphabetically, and for `instagram` and `linkedin`, only the handle is necessary.
2. Put their logo in `images/member_org_logos/`.

### Adding a press mention

1. Create a new item in `_data/press.yml`. Note that we list press mentions in descending order by publication date (`date`).
2. Optionally, set the `category` attribute to link the press mention to a particular initiative. This will make the press mention show up at the bottom of that initiative's page. To see what string should be listed to link it to the appropriate initiative, check the `.html` file for that initiative in `_initiatives/` and towards the bottom look for a line like `{% if article.category contains 'Congressional Visits' %}` which is the logic that loops through categories to determine which related press mentions to show. Note that you can link a press mention to multiple initiatives by itemizing them, e.g.,
  ```
  category:
    - Congressional Visits
    - McClinktock Letters
  ```
