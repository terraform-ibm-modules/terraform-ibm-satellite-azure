# Contributing

Please refer following link for [contribution guidelines](https://github.com/terraform-ibm-modules/getting-started/blob/master/contribution_guidelines.md)

## Directory structure

The project has the following folders and files:
```
├── .github/
│   ├── workflows/
│   │   ├── workflow_file1.yml
│   │   ├── .../
├── README.md
├── versions.tf
├── variables.tf
├── main.tf
├── outputs.tf
├── module.yaml
├── .pre-commit-config.yaml
├── modules/
│   ├── nestedA/
│   │   ├── README.md
│   │   ├── variables.tf
│   │   ├── main.tf
│   │   ├── outputs.tf
│   ├── nestedB/
│   ├── .../
├── examples/
│   ├── exampleA/
│   │   ├── main.tf
│   ├── exampleB/
│   ├── .../
├── LICENSE
├── CONTRIBUTING.md
├── CHANGELOG.md
├── test/
│   ├── test_file1.go/
│   ├── .../

```

Please make sure you are changes are inline with directory structure mentined as above.

For more information on directory structure, design guidelines and contribution gudilines [refer](https://github.com/terraform-ibm-modules/getting-started)