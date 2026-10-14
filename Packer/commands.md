# Commands to run for the Practical

1. Validate

   ```
   packer.exe validate --var-file packer-vars.json packer.json
   ```

   Checks the Packer template for configuration and syntax errors before building the AMI.
2. Inspect

   ```
   packer.exe inspect --var-file packer-vars.json packer.json
   ```

   Displays information about the template, such as its builders, provisioners, and variables.
3. Build

   ```
   packer.exe build --var-file packer-vars.json packer.json
   ```

   Executes the template: launches a temporary EC2 instance, installs and configures tools, creates the AMI, and cleans up temporary resources.

Typical workflow: `validate → inspect (optional) → build`
---

Yes, Packer has other useful commands too. There is no standard `verify` command in Packer, but you can use these:

| Command                           | Purpose                                                                 |
| --------------------------------- | ----------------------------------------------------------------------- |
| `packer.exe version`              | Displays the installed Packer version.                                  |
| `packer.exe fmt packer.json`      | Formats the template.                                                   |
| `packer.exe validate packer.json` | Validates template configuration.                                       |
| `packer.exe inspect packer.json`  | Shows template details.                                                 |
| `packer.exe init .`               | Installs required plugins for modern HCL templates.                     |
| `packer.exe build packer.json`    | Builds the AMI.                                                         |
| `packer.exe console packer.json`  | Opens an interactive console for evaluating template expressions (HCL). |

### How do you verify the AMI after building?

Packer doesn't have a dedicated `verify` command. Instead, you can:

- Check the build output for the generated AMI ID.
- Verify in AWS CLI:

  ```
  aws ec2 describe-images --owners self --region us-east-1
  ```

- Test the AMI: Launch a test EC2 instance from it and verify that the installed tools and services work.

Note: Your current `packer.json` uses the legacy JSON template format. Commands such as `fmt` and `validate` have different support and options depending on whether you're using legacy JSON or modern HCL (`.pkr.hcl`) templates.
