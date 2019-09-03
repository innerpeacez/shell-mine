#!/bin/bash
repo="私有仓库地址"
images=`cat images.txt`
for image in ${images};
do
  echo "docker pull ${image}"
  docker pull ${image}
  tag=${image#*:}
  image_profix=${image##*/}
  image_name=${image_profix%%:*}
  pushName=${repo}/${image_name}:${tag}
  echo "docker tag ${image} ${pushName}"
  docker tag ${image} ${pushName}
  echo "docker push ${pushName}"
  docker push ${pushName}
  echo "--------------------------------"
done