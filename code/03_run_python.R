
#########################################################################################
# ENSURE THE VENV_FOLDER VARIABLE IS SET TO THE NAME OF YOUR PYTHON VIRTUAL ENVIRONMENT #
# Set virtual environment folder name                                                   #                              
VENV_FOLDER <- ".venv_ud_complexity"                                                    #                   
#########################################################################################

# Check the venv_folder exists
if (!dir.exists(paste0("../", VENV_FOLDER))) {

  # Get the name of the current script
  script_name <- "03_run_python.R"
  
  stop(paste("Virtual environment", VENV_FOLDER, "not found. Please create a virtual environment, install the project as described in the README, and update", script_name, "as necessary before running."))
}

# Detect OS and set python path accordingly
venv_python <- if (.Platform$OS.type == "windows") {
  paste0("../", VENV_FOLDER, "/Scripts/python.exe")
} else {
  paste0("../", VENV_FOLDER, "/bin/python")
}

# Call the script using the virtual environment's python
system2(venv_python, args = "../pycode_ud/wrapper.py")