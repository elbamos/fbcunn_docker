Here's how I get this party started:
```
sudo docker build -t kmatzen/fbcunn .
sudo docker run -t -i --net=host --privileged -v /mnt/drive/kmatzen/ilsvrc12:/ilsvrc12 -v /lib/modules:/lib/modules -v /tmp/torch_cache:/torch_cache kmatzen/fbcunn
```

I assume the CUDA driver is installed on your machine.

* You need ```--privileged``` for the container to access your nvidia devices.  You can grant a finer-grained permission using lxc.
* You probably want to access your data inside the container.  That's what ```-v /mnt/drive/kmatzen/ilsvrc12:/ilsvrc12``` is for.
* You might need to mount the hosts' /lib/modules.  That's the point of ```-v /lib/modules:/lib/modules```.
* Unless you want your work to be blown away with the container, stick the torch cache somewhere on the host filesystem with ```-v /tmp/torch_cache:/torch_cache```.

This isn't the best configuration, but it gets things going quickly.

Please take a look at the actual Dockerfile.  Some steps from the fbcunn installation instructions didn't work quite right, so I hacked around them.

Want a quick way to figure out if everything is configured correctly for your GPU?  Start the container, run ```th``` and execute the following code:
```
require 'cutorch'
torch.setdefaulttensortype('torch.CudaTensor')
print(  cutorch.getDeviceProperties(cutorch.getDevice()) )
```
Did it print your device?  Good.  Did it print something like:
```
th> require 'cutorch'
/torch-distro/install/share/lua/5.1/trepl/init.lua:319: loop or previous error loading module 'cutorch'
stack traceback:
  [C]: in function 'error'
  /torch-distro/install/share/lua/5.1/trepl/init.lua:319: in function 'require'
  [string "require 'cutorch'"]:1: in main chunk
  [C]: in function 'xpcall'
  /torch-distro/install/share/lua/5.1/trepl/init.lua:588: in function 'repl'
  /torch-distro/install/lib/luarocks/rocks/trepl/scm-1/bin/th:185: in main chunk
  [C]: at 0x00406170
                                                                      [0.0002s]
```
Then check to make sure you provided ```--privileged```.
Do you actually need to mount ```/lib/modules```?  Don't know.  cutorch seems fine without it.  Other CUDA software I've used in Docker needs it.
