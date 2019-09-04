sudo sysctl -w vm.drop_caches=3
sudo sysctl -w vm.drop_caches=1
echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
echo `date -R` >> ~/clear_cache_logs.txt
free -lh >> ~/clear_cache_logs.txt
