name: backup
on: push
  
jobs:
  backup-job:
    runs-on: ubuntu-20.04
    steps:
      - name: Run build script
        run: ./scripts/auto-upgrade.sh
        shell: bash
