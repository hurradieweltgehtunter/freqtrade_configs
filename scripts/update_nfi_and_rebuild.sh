#!/bin/sh

### Simple script that does the following:
## 1. Pull NFIX repo
## 2. Stop, Pull, and Start freqtrader via docker compose
## 3. Make it executable: chmod +x update_nfi_and_rebuild.sh
## 4. add cronjob: crontab -e -> 0 */6 * * * /Users/fl.lenz/Desktop/projects/ft_userdata/update_nfi_and_rebuild.sh

NFI_LOCAL_REPO=/Users/flo/Desktop/freqtrader/user_data/strategies/NostalgiaForInfinity

# pull from NFIX repo
echo "updating local NFIX repo"
cd $NFI_LOCAL_REPO
latest_local_commit=$(git rev-parse HEAD)
git pull
latest_remote_commit=$(git rev-parse HEAD)

if [ "$latest_local_commit" != "$latest_remote_commit" ]; then
    # Copy the updated strategy to the strategies directory
    echo "[INFO] Copying updated strategy to strategies directory..."
    cp $NFI_LOCAL_REPO/NostalgiaForInfinityX5.py /Users/flo/Desktop/freqtrader/user_data/strategies/NostalgiaForInfinityX5.py
    cp $NFI_LOCAL_REPO/NostalgiaForInfinityX6.py /Users/flo/Desktop/freqtrader/user_data/strategies/NostalgiaForInfinityX6.py

    cd /Users/flo/Desktop/freqtrader
    echo "restarting freqtrade with NFIX"
    docker compose pull
    docker compose stop
    docker compose up -d
fi
