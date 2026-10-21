# 1. Install uv (if not yet installed)
Windows:
`powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"`

MacOS & Linux:
`curl -LsSf https://astral.sh/uv/install.sh | sh`


# 2. Download .zip file from Github
Unzip the file to EEG_demos

# 3. Open VS Code in the correct folder
Open VS Code
Click File > Open Folder

# 4. Sync environment as intended by instructor
Open a terminal in VS code and run:
`uv sync`

# 5. Run your app/test/script
`uv run my-script`         # if defined in pyproject.toml [project.scripts]  
`uv run python script.py`  # for any script