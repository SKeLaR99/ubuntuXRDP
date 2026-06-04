```bash
----------Forked from HopingBoyz/DebianXRDP but deforked later on--------------------
docker build -t ubuntuxrdp .


docker run -d -p 3389:3389 -v ubuntuxrdp-home:/home/ubuntu --name ubuntuxrdp ubuntuxrdp

---------------------------------------------------------------------------------------
