# Convert PDF to Markdown Format

1. Create a .md file with the same filename as the specified PDF in the same directory.
2. Read the PDF and output its section structure in Markdown format to the Markdown file. Section numbers must follow the PDF's numbering.
3. For each section, generate a subtask: "Convert this section's content to Markdown format and insert it into the corresponding section of the Markdown file. Separate each paragraph with a blank line."
4. Execute the generated subtasks in order.
5. Check each section one by one to ensure no empty sections exist. Correct any empty sections found.
6. Run `pnpx markdownlint-cli2 <markdown filename>` to check formatting and correct any errors.
