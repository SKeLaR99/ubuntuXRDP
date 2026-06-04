```bash
----------Forked from HopingBoyz/DebianXRDP but deforked later on--------------------
docker build -t ubuntuxrdp .

docker run -d \
  -p 3389:3389 \
  -p 6080:6080 \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v ubuntuxrdp-home:/home/codespace \
  --name ubuntuxrdp \
  ubuntuxrdp
---------------------------------------------------------------------------------------
