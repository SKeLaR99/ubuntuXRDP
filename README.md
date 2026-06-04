```bash
----------Forked from HopingBoyz/DebianXRDP but deforked later on--------------------
docker build -t ubuntuxrdp .

docker run -d \
  -p 3389:3389 \
  -p 6080:6080 \
  --name ubuntuxrdp \
  ubuntuxrdp
---------------------------------------------------------------------------------------
