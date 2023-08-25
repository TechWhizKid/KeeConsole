import sys
import shutil

# Get the terminal width
terminal_width = shutil.get_terminal_size().columns

# Retrieve the title from command-line arguments
title = ' '.join(sys.argv[1:])

# Calculate the padding for the title
title_padding = (terminal_width - len(title) - 2) // 2
left_padding = title_padding
right_padding = terminal_width - len(title) - 2 - left_padding

# Print the top line of "="
print('=' * terminal_width)

# Print the title line
print('|' + ' ' * left_padding + title + ' ' * right_padding + '|')

# Print the bottom line of "="
print('=' * terminal_width)
