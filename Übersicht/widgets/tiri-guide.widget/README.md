# Tiri Guide Widget

A Übersicht widget that displays upcoming Tiritiri Matangi guide trips from your calendar.

## Setup

1. **Configure your private settings:**
   - Copy `config.example.json` to `config.json`
   - Edit `config.json` with your personal information:
     - `CALENDAR_NAME`: Your calendar name/email
     - `OBSIDIAN_VAULT_NAME`: Your Obsidian vault name
     - `OBSIDIAN_NOTE_PATH`: Path to your guiding notes in Obsidian

2. **The `config.json` file is already in `.gitignore`** - your private info won't be committed to git.

## Features

- Shows countdown to next Tiritiri Matangi guide trip
- Displays up to 5 upcoming trips
- Click on any date to open Calendar.app to that date
- Click on the icon to open your Obsidian guiding notes
- Alert styling when trip is less than 3 days away

## Requirements

- `icalBuddy` installed (via Homebrew: `brew install ical-buddy`)
- macOS Calendar.app with events containing "Tiritiri" in the title
- Obsidian (optional, for note opening feature)

