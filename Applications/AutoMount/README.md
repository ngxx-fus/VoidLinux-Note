# AutoMount Service (Runit / Void Linux)

Automated partition detection, directory verification, and read-only mount service managed by Runit on Void Linux.

## Project Structure

```text
AutoMount/
├── AutoMount.sh        # Core execution script
├── README.md           # Documentation
├── .gitignore          # Git exclusion rules
└── service/            # Runit service definition template
    ├── run             # Main service run script
    └── log/
        └── run         # Log management run script (svlogd)
