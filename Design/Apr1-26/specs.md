# Initial BRD

- This project is under `Projects/AgentCraft` and will be used to define the agent skills for all other projects. It will use the agent skills of this repository: https://github.com/addyosmani/agent-skills
- The source code of the agent skills is under `agent-skills`.
- Tasks:
0. Write a README.md file that explains what this project does and how to use it.
1. Create a script `scripts/get-updates.sh` that will run `git pull origin main` inside directory `agent-skills` to get the latest updates. The latest updates should be included in the README.md file for each skill. 
2. Create a script `scripts/createagents.sh` that will run on specific projects, for example `./createagents.sh Projects/project1`, and will copy the necessary skills to the project directory. It should accept one of the following arguments:
2.1 Tool type: `github-copilot` or `opencode`.
 - Opencode instructions can be found at https://github.com/addyosmani/agent-skills/blob/main/docs/opencode-setup.md
- GitHub Copilot instructions can be found at https://github.com/addyosmani/agent-skills/blob/main/docs/copilot-setup.md
2.2 Skills Available 
- The skills available should be clearly listed in README.md. The user can run the script with an additional argument to specify which skills to copy, for example `./createagents.sh --path Projects/project1 --tool github-copilot`. If no argument is provided, all skills should be copied.
- If specific skills are only to be used for a specific tool, they should be clearly marked. For example `./createagents.sh --path Projects/project1 --tool github-copilot --skills 1 2 3` where skills 1 2 3 are clearly explained in README.md file. In this case, only skills 1 2 3 should be copied to the project directory. 