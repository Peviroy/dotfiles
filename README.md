# <p align="center">MY DOTFILES </p> 

## Preface

所谓兴致匆匆也不过如是了.

到目前为止已经沉浸在此10天.

我深知在一个将不断迭代的文档中记录下日期并不合适.只是在面对目前这份近5k字却分明只是刚刚起步的文章时,我无法置身事外写着陈述性的文字.

<br/>

曾是一名plasma用户,这段历时足足两年有余. 而又是什么因素在催促着我这个连blog都能弃坑的懒癌患者在此进行着微不足道的输出呢? 这大概有三方面.

首先是正值换电脑,我打算从manjaro跑到arch看看.而arch是无拘无束的,从命令行开始的航行让我明白前方并不只有KDE等知名的桌面环境.

其次是一位up@TheCW给我展现了我此前未曾知晓的tilling window manger及全键盘控制的愉悦感.当然还有其期望为开源社区贡献力量的决心与努力.

另外,在目前正在进行的配置过程中,我深感开源社区的伟大,也是由此我方才在安装完Arch,配置完KDE与初步开展Bspwm后克服阻力开启此文.

<br>

也是有些魔幻的,不就之前还是个"能用就行nano党",还是个"kde真好看",还是一个"qwerty能用换什么键位".转眼就采用了截然相反的文本输入方法,桌面操作方案,键位布局.这一定程度上得益于时值假期,能够有充足的时间去捣腾,去适应阵痛.这也一定程度让我明白改变可以是巨大的.当然了,样本不过是未及核心的毛皮之变,但终归是提供了一种可能性的愿景.

<br>

目前的文档其实是十分不完善的,不仅体现在完成度上,也体现在内容上.作为一个README这只能是作为一个过渡,而后自然是要以更简练的语言去描述.但这并非是没有意义的.README正文的进度将在未来开启,而在此之前先让我们走完这段心路.

<br>

<br>



# Configure Arch & Bspwm & Polybar

### Hardware environment

* CPU: i5-1135G7
* GPU: intel Iris Xe (using i915driver)
* GPU: Nvidia MX450
* Resolution: 2880x1800



## Arch installing(pre-in-post )

setfont ter-132n



<br>

### [Time] confict

Win10是用local time, 而Arch使用universal time.若是不加以处理，其中一个OS的正确时间将导致另一个的失准。判断所使用的linux distro.

**`Plan A：force Win10 to use UTC (recommanded)`**

```batch
Reg add HKLM\SYSTEM\CurrentControlSet\Control\TimeZoneInformation /v RealTimeIsUniversal /t REG_QWORD /d 1
```

**`Plan B：disable UTC and use Local Time in Arch`**

```bash
#timedatectl set-local-rtc 1 --adjust-system-clock
```

<br>

<br>

### [Suspend]Hibernate

作为一个坚定的休眠党，`suspend to disk(hibernate)`是无法拒绝的，也正因此才在最开始分区时分配了内存大小的SWAP分区。

不同于suspend to ram的开箱即用，hibernate需要进行一些指定以及兼容性工作。

此处仅仅展示使用swap partition的情况，使用swap file会稍微麻烦些，但更灵活。(尤其是hibernate并不需要swap space larger than RAM)，此处尽是搬运整理，更全面的教程请寻找archwiki.

**`1. Kernel parameters`** 

关键在于告知系统去将内容保存在哪里，同时也知道启动时去哪里读取，这就需要向内核传递信息。有三种方式，而最为常用的是借助boot loader。

**To where**	grub应当是目前最为流行的boot loader了，其配置在`/etc/default/grub`的`GRUB_CMDLINE_LINUX_DEFAULT`条目。

**To what**  在ext4分区的swap上，有两种parameter的形式

```
resume="PARTLABEL=<swap partition>"  # use #fdisk -l or any to get
resume=UUID=<swap partition uuid>    # use #blkid PARTLABEL
```

**`2. Update grub file`**

如果没问题，将到此为止，不过在使用前还有两步：

```sh
$sudo grub-mkconfig -o /boot/grub/grub.cfg
$reboot
```

而后可以使用`systemctl hibernate`进行休眠了。

**`3. Solve compatiblity problems`**

兼容性问题各异，此处仅展示我所遇到的。全面的troubleshoting见arch wiki.

我的问题是黑屏问题，而这点我在wiki下找到描述:

> For Intel graphics drivers, enabling early KMS may help to solve the blank screen issue. Refer to [Kernel mode setting#Early KMS start](https://wiki.archlinux.org/index.php/Kernel_mode_setting#Early_KMS_start) for details.
>
> ---
>
> KMS is typically initialized after the [initramfs stage](https://wiki.archlinux.org/index.php/Arch_boot_process#initramfs). However it is possible to already enable KMS during the initramfs stage. Add the required module for the [video driver](https://wiki.archlinux.org/index.php/Xorg#Driver_installation) to the `MODULES` array in `/etc/mkinitcpio.conf`:
>
> - `amdgpu` for [AMDGPU](https://wiki.archlinux.org/index.php/AMDGPU), or `radeon` when using the legacy [ATI](https://wiki.archlinux.org/index.php/ATI) driver.
>
> - `i915` for [Intel graphics](https://wiki.archlinux.org/index.php/Intel_graphics).
>
> - `nouveau` for the open-source [Nouveau](https://wiki.archlinux.org/index.php/Nouveau) driver.
>
> - `mgag200` for Matrox graphics.
>
> - Depending on [QEMU](https://wiki.archlinux.org/index.php/QEMU) graphics in use: `virtio-gpu` for VirtIO, `qxl` for QXL, or `cirrus` for Cirrus.
>
>   

因为我所使用的驱动是i915(可由$inxi -G)，因此进行fix如下：

```
/etc/mkinitcpio.conf
---
MODULES=(... i915 ...)
```

并更新内核

```sh
sudo mkinitcpio -P
```



**`参考`**

[Arch wiki:Power management/Suspend and hibernate](https://wiki.archlinux.org/index.php/Power_management/Suspend_and_hibernate)

<br><br>

### [Driver]Audio

arch-base并没有提供声卡驱动，因此若需要手动安装。在此过程中将遇见两个重要的名词：[Advanced Linux Sound Architecture](https://en.wikipedia.org/wiki/Advanced_Linux_Sound_Architecture) (**ALSA**) 与[PulseAudio](https://en.wikipedia.org/wiki/PulseAudio)。前者作为Drive不过也provide library作为userpace component(有时显得和PulseAudio抢工作)，后者作为Sound server是驱动与应用之间的媒介。

**`ALSA`**

```bash
# packagebase | utilities | for high quality resampling
$sudo pacman -S alsa alsa-utils alsa-plugins 
# ALSA Firmware
$sudo pacman -S alsa-firmware 
# ALSA Firmware (If audio device use driver 'sof'; see $inxi -A)
$sudo pacman -S sof-firmware alsa-ucm-conf
```

**`PulseAudio`**

```sh
# for PulseAudio to manage ALSA as well | for bluetooth support (Bluez),
$sudo pacman -S pulseaudio-alsa pulseaudio-bluetooth
```

<br><br>

### [Driver]Bluetooth

熟悉了DE下全GUI的蓝牙控制方式，难免会对CLI方式操作蓝牙有所抵触，但请相信，使用`bluetoothctl`不仅相当容易上手而且将让我们看到此前从未关注的内容。

**`1. Install bluz`**

linux下的蓝牙控制套件集成为bluz。

```sh
$sudo pacman -S bluz
```

**`2. How to connect`**

1. Run bluetoothctl and init it

   ```sh
   $ bluetoothctl
   ...  turn the power to the controller on
   [bluetooth]# power on
   [bluetooth]# agent on
   [bluetooth]# default-agent
   ```

2.  Find your device mac address

   ```sh
   [bluetooth]# scan on
   ... find device mac address 
   ... or use devices to list mac address after it found
   [bluetooth]# devices
   ```

3. Connect it

   ```
   [bluetooth]# pair <mac address>
   [bluetooth]# trust <mac address>
   [bluetooth]# connect <mac address>
   ```

   当然也可以不trust, 但有可能无法connect上

4. Set-alias if jou like

   ```
   [device name]# set-alias blahblah
   ```

**`3. Set auto power-on`**

若是使用蓝牙设备作为外设，自然希望开机自动启动。但可惜默认情况下蓝牙服务并不自动启动。方案如下：

```sh
/etc/bluetooth/main.conf

[Policy]
AutoEnable=true
```

**`4.  Headset device with PulseAudio`**

使用蓝牙声音输出时同键鼠有所不同，因此需要额外配置。

在进行蓝牙连接时，往往会报错：

```
[bluetooth]# connect <mac address>
...org.bluez.Error.Failed...
```

这时，可以尝试如下：

```
$ pulseaudio -k
[bluetooth]# connect 00:1D:43:6D:03:26
```

若正常连接那么很幸运，若仍旧无法成功，那么查询一下系统日志：

```sh
# systemctl status bluetooth
# journalctl -n 20
...
bluetoothd[5556]: a2dp-sink profile connect failed for 00:1D:43:6D:03:26: Protocol not available
```

这有几种情况,而最为寻常的是没有安装[pulseaudio-bluetooth](https://archlinux.org/packages/?name=pulseaudio-bluetooth) (Audio模块已经提示)，此时安装后重启pulseaudio服务(systemctl --user restart pulseaudio.service)再度测试测试。而其他情况则相当繁琐，此时最好详细查询下[wiki](https://wiki.archlinux.org/index.php/bluetooth_headset#Pairing_fails_with_AuthenticationFailed)

**`参考`**

[Archwiki-bluetooth](https://wiki.archlinux.org/index.php/Bluetooth#Auto_power-on_after_boot)

[Archwiki-bluetooth headset](https://wiki.archlinux.org/index.php/bluetooth_headset)

<br><br>

### [Shell]Share rc

虽然绝大多数linux distro.还是将bash作为loginshell,但恐怕已经很少人单纯使用bash了.而在多个shell下我们自然是希望它们能共享一些基础性配置而非每个shell都分别进行重复性配置.对此,我们无需大刀阔斧,只需进行一小部分删改即可.当然前提是shell在一些语法上有所兼容,至于fish和bash之间,便不建议了.此处以zsh and bash为例.

**`Shell loading order`**

包括zsh的配置在内，bash以及系统级的config file让整个shellrc相当复杂。而这些文件并非同时加载的，而是有取舍，有[先后顺序](https://shreevatsa.wordpress.com/2008/03/30/zshbash-startup-files-loading-order-bashrc-zshrc-etc/)。而理解了加载链才能让我们不至于配置写错地方而没有被加载.

根据上面所述[文章](https://shreevatsa.wordpress.com/2008/03/30/zshbash-startup-files-loading-order-bashrc-zshrc-etc/), 无论在login还是non-login下,zshrc都是被加载的,而bash则不存在同时在两种情况下都加载的文件.不过还好,因为使用zsh作为主力shell,bash的问题是容易解决的.

**`My configuration`**

使用`~/.profile`(read by bash when login)作为公共项,让`~/.zshrc`与`~/.bashrc`读取其中内容.

In `~/.bashrc`:

```sh
source ~/.profile
```

In `~/.zshrc`:

```sh
[[ -e ~/.profile ]] && emulate sh -c 'source ~/.profile'
```

<br><br>

### [Display]High DPI

在完成安装之后，兴冲冲地reboot而后login session,虽然早已经抱好了将面对简陋至极的页面预期，但当真正看到登陆时的以dm为背景（没有配置壁纸），且字体极小的展示效果时（HiDPI屏幕），小心脏仍受到了不小的打击。

好吧，先撇开美化问题，过小的字体显然是无法接受的，而这一切源自于我们的这块HiDPI display屏幕。因为默认是没有缩放改变的，所有的元素占据了缺省的像素点，而因`Dots Per Inch（DPI）`过大，那么‘元素’就将显小。所以这是过高分辨率带来的适配性问题。若彼时的我或此时的你没有此烦恼那么大可跳过。不过此处的方法对于希望在WM环境下进行`resolution scaling`还是有一些意义的。



在Arch Wiki上有专门对于这个问题的[页面](https://wiki.archlinux.org/index.php/HiDPI)，简单地过目了一下，在当前环境下推荐的是使用`xrandr`来进行调整。

**调整的方式是直接调整DPI而非调整分辨率**，这是有道理的。因为调整分辨率改变的是输出的像素数目，缩放分辨率不会带来精细度改变，若是放大那么将因为分辨率降低而只会显得糊眼睛。**真正的缩放是对DPI的缩放**。在分辨率不变的情况下，使用更高的DPI就将用更多的像素点用于显示同一个‘视觉元素’，因此就仿佛所有图案都放大了一般。（注：此处的DPI缩放并非硬件层面的缩放，毕竟硬件DPI（PPI）的固定的。此处DPI更倾向于理解成用多少像素去表示一个固定大小的数字图案，DPI越大，在屏幕上就显得越大）

因此若要确定放缩，第一步便是确定当前DPI,而后计算并设置放缩后的DPI：

1. 获取DPI

   ```bash
   $ xdpyinfo | grep -B 2 resolution
   ```

2. 更新DPI

   因为使用xrandr来设置，那么当是每当登陆session便执行一次。这可以放置在`.xinitrc`下，但此文件会被每一个session（dm也会）读取，因此在多DE或WM情况下，若不希望给到全局影响，最好还是在DE或WM各自特定的文件中进行设置，譬如在bspwm下，便可在`~/.config/bspwm/bspwmrc`中添加：

   ```bash
   xrandr --dpi 144  # 96x1.5
   export GDK_DPI_SCALE=1.5  # 适用于GDK应用
   ```



补充：

1. wiki中，#Gnome#Xorg下的案例（用xrandr scale）给找到正确方案添堵不少，这或许在Gnome下如此但，但在当前情况并不可行，因为这会直接scale分辨率:(

2. 其实DPI scaling虽然能在DE下使用GUI工具进行调整。但这并非其专属，而使用DW也不一定非要在终端中敲敲命令，虚拟桌面环境提供的一些工具如``gnome-settings`, `lxappearance` 其实也能达到同样的效果。毕竟调整DPI,其底层都是基于XServer。

参考：

[Github-issue-bspwm-HiDPI](https://github.com/baskerville/bspwm/issues/631)

[Arch Wiki-HiDPI](https://wiki.archlinux.org/index.php/HiDPI)

<br><br>

### [Nvidia]optimus-manager

在使用manjaro时,便使用着optimus技术来控制双显卡了,而这也是我当时选择manjaro的一个最主要原因:manjaro官方支持显卡驱动的快捷安装方式.这最初是`Bumblebee`而后是`Prime`.

但bumblebee性能释放不行,而prime在arch下没有manjaro社区版本因而无法`use both`, 那如何呢?`nouveau`比bumblebee还不行,`nvidia-xrun`又是独立开一个session,这不符合hybrid的预期.

最终的选择是`optimus-manager`.这是个unofficial的方案,但目前已经有了相当多的co-contributors,虽然曾有所顾虑,但实际上体验相当地流畅,性能表现不输于win10端.总之,对于**arch\arch-based,Xorg**用户,力荐.

**`how to install`**

开发者提供了[aur]optimus-manager,但由于需要同时安装python package dependency(python滚动更新), 现成的wheel可能会有`python version conflict`.所以最好的方式是自己编译.

```sh
$ git clone https://aur.archlinux.org/optimus-manager.git
$ cd optimus-manager
$ makepkg -si
$ reboot
```

**`how to use`**

其提供了intel, hybrid, nvidia的选项. 对于我来说hybrid是更好的,毕竟使用nvidia会涉及到重新配置图形显示相关,且并不方便.

```:sh
$ optimus-manager -switch hybrid
```

hybrid下提供激活了nvidia,但默认情况并不调用,调用的方式是:

* 通过在程序前添加下列环境

  ```
  # dont export global
  __NV_PRIME_RENDER_OFFLOAD=1 __GLX_VENDOR_LIBRARY_NAME="nvidia" __VK_LAYER_NV_optimus="NVIDIA_only" __GL_SHOW_GRAPHICS_OSD=1
  ```

  <br><br>

---

<br><br>

## Bspwm

不仅仅是bspwm的配置，或者称之为`post-arch-install`更为合适。因为原生的arch是精简的，bspwm也是，因此如果不加以配置，乃至连curl都是不支持的。所以进行一定的配置是必要的，但我将**这些配置统统放在bspwm下**不是想要打造bspwm成为一个desktop environment。而是期望以bspwm为中心，建造一个符合心意的GUI以及CLI环境。

<br>

### [Wallpaper, blur] feh & pywal

`@tl;dr: wallpaper manager and image viewer `

若是不希望一打开便是以display manager的图案为壁纸，或是因自动login或无display manager而呈现灰色壁纸，那么先配置壁纸无疑是明智的。

feh之外nitrogen也是有名的壁纸管理器，但feh好在集成了随即选择壁纸的功能，这让我们能在注册快捷键后一键切换壁纸。同时这也能胜任精简图片浏览器，且sidebar而能够沉浸式展示图片。

**`Wallpaper starts at login`**

```sh
~/.config/bspwmrc
---
# Set background image randonly with feh
feh --bg-fill --no-fehbg --randomize $HOME/Pictures/Home_Slide/*
```

<br>

**`Update for pywal`**

原以为pywal使用来提取color scheme的,远没有想到其还能用于设置壁纸.

若是但从壁纸管理角度来看,pywal的功能面是不如feh.但其提取color scheme的功能带来了相当多的可拓展性.不过目前我并不打算贸然使用此功能,毕竟色彩搭配是需要花费一定经历的.

而我之所以会找到pywal源自于我对于毛玻璃效果或退而求其次的模糊效果的追寻.窗口渲染器picom的blur相对有些bad performance,毕竟要对每个窗口负责. 不过若是**让壁纸去模糊**会是一个折衷的选择.

对此我找到了两个相应的脚本,一个是[ngynLk@feh-blur-wallpaper](https://github.com/ngynLk/feh-blur-wallpaper)(baed on rstacruz's), 另一个是      兼容了pywal的[mut-ex@wallblur](https://github.com/mut-ex/wallblur).当然两者底层逻辑都是使用feh来展示模糊处理后的壁纸,但前者虽然开销较小,但模糊的效果并不如后者自然.

* feh-blur-wallpaper

  make feh cache itself: 

  ```
  feh --bg-fill --no-fehbg   -> feh --bg-fill
  ```

  ```
  # add to startup file
  /path/to/feh-blur -d
  ```

* wallblur

  replcae feh with pywal

  ```
  wal  -ste -lq -i <imagedir>
  # s:dont change termical color
  # t:dont change tty color
  # e:dont reloade gtk/xrdb/i3/sway/polybar 
  # l:generate lightcolor scheme (while i wont use it now)
  # q:quiet
  # i:indicate to the image or directory 
  ```

  ```
  # add to startup file
  /path/to/wallbulr.sh &
  ```

**`Dependencies`**

For feh-blur-wallpaper

* ```
  graphicsmagick wmctrl feh
  ```

For wallblur:

* ```
  imagemagick wmctrl feh python-wallblur(python)
  ```



<br>

<br>

### [Core] vim

`@tl;dr: needless to say`

如果说我为何要换一套键盘布局,为何要换一套桌面模式,其目的就在于追求对以vim为核心之一的键盘操控方案.我诚欲有所建言,然钻研不深,来我这看vim教程是不合适的.

<br><br>



### [Launcher] rofi

<br><br>

### [Copaste] xsel

`@tl;dr： get a fixed string into the clipboard`

如果使用过Gnome、Plasma等桌面，想必使用过一键输出密码，毕竟权限密码记得长了的话还是快捷键来得方便。而bepwm是concise的，没有提供相关功能。

`xsel`是这么介绍自己的：Manipulate the X selection。这么说或许有些晦涩，换句话说，可以这么解释：

> The simple and versatile xsel utility bridges the gap between the Unix  pipeline and the clipboard functionality of the X Window System.    
>
> @Chad Perrin/Use xsel to copy text between CLI and GUI

于是通过xsel, 得以轻松地将字段输出到剪切板，而后只需paste即可。

#### how to use

在sxhkd中注册快捷键如下：

```
super + alt + v
         bash -c "xsel -ib < $HOME/.config/.passwd"
```

<br><br>

### [IM] fcitx5-im

`@tl;dr: may be a new fcitx better for Chinese user`

曾使用过fcitx+rime, 这一度是我的主力输入法。而我抱着侥幸的心理安装了fcitx5后,其凭借其丝滑与良好的词库反馈让我成功真香。

I used to deploy fcitx&rime as my major input method. But after i tried fcitx5 for a while, its fluenquency as well as its great dictionaries conquer me wholely. See [拥抱 Fcitx5](https://blog.coelacanthus.moe/tech/welcome-to-fcitx5/) for detail.

#### dependency

* Main - fcitx5-im
* Theme - fcitx5-material-color
* Dict - fcitx5-pinyin-zhwiki ....

<br><br>

### [Theme] set cursor themes

`@tl;dr:  set cursor for Xresourcer and display managers` 

默认的指针未免显得有些黑且干，这与`Breeze Snow`形成了鲜明对比。因此我会选择切换cursor theme而非默认。

**`X resources`**

```
~/.Xresources
---
Xcursor.theme: Breeze_Snow
```

当然，除此之外还可以采用XDG的途径来做，但无论如何**这已经能在任何软件界面上**显示所希望的cursor theme.

**然而**,可惜的当cursor处于桌面上时,cursor theme是失效的.这或许同我使用了DM有关.

**`Display manager`**

我所使用的是SDDM,其配置文件为 /usr/lib/sddm/sddm.conf.d/default.conf, 因此在其中找到cursor词条并更改.

事实也的确如此,本身应当只影响登陆界面的设置在桌面上生效了.

```
/usr/lib/sddm/sddm.conf.d/default.conf
---
CursorTheme= Breeze_Snow
```

**`Cursor theme`**

Theme,不仅是cursor theme有系统级别作用域也有用户级.前者路径为`/usr/share/themes`而后者路径为`~/.local/share/themes`. 或许Xresources使用用户级即可,但对于Display manager来说,唯有使用系统级才行.

此处的`Breeze_Snow`可以经搜索`breeze-icons`来安装.而若是没有现成的package又希望能安装在/usr/share/themes下,那么需要自行创建package,否则未必被系统认可

<br><br>

### [Theme] apply gtk and qt themes to APPs

`@tl;dr: it may take pains to do this but worthwhile`

这或许听起来有些奇怪,毕竟之所以追求使用tilling window manager就是冲着键盘操作为核心去的,我们可能期望用着终端模拟器做任何事,而gtk和qt所写的APP都是GUI.

但终归是逃不掉图形化软件的使用的,而且也没必要.

另外,一个合适的theme将能同现有的自制桌面色调大大协同.

除了firefox外,我还是一个坚定的Typoraer(因其出色的即时渲染),而typora是使用gtk theme的(同firefox一样). 此外因之前是plasma用户,所以对dolphin情有独钟(即便有ranger了),而这是一个QT程序.同样的还有clementine,这是使用的第一个也是唯一一个本的音乐播放器,即便默认皮肤有些续不好看.但这更坚定了我换theme的决心.

坦白说搞明白如何将theme正确地apply,花费了我不少时间.因为以window manger为核心自制的desktop environment相比于完善的DE是缺少对这方面的支持的.

而且配置这些东西使用GUI软件相较于在敲命令是更妥帖的方式.在这方面来说配置qt theme要甚于配置gtk theme.

**`GTK THEME`**

* where GTK theme saves.

  /usr/share/themes 以及 ~/.local/share/themes是两个存放区域.相较于qt(kde theme)其存储区域是简洁明了的

* how to apply GTK theme

  gtk2貌似繁琐些,对于gtk3(gdk)而言,在目标仅仅是目标只在于字体,icon,theme等的情况下, 配置`.config/gtk-3.0/settings.ini`即可.其[example](https://wiki.archlinux.org/index.php/GTK#Examples)可在此找到.

  此外还可以选择使用`lxappearance`来调用图形化配置.这虽本身为LXDE设计,但安装时无需相关环境.

**`QT THEME`**

在我看来qt是较强耦合于plasma(KDE)的(或许有误).因为plasma(KDE)建立在QT之上,所以想单独找到qt theme并不容易. 

因为我在bspwm之前安装了plasma,所以我能在`~/.kde`下找到我plasma桌面的qt theme setting.但企图在终端下直接更改其配置是徒劳的.而且将发现其设置影响不到bspwm下的qt app.

这是由于所谓`QT THEME`倒不如说是`KDE THEME`,而环境变量`$DESKTOP_SESSION`告诉我们,这是bspwm而非plasma, 而且`$XDG_CURRENT_DESKTOP`是null. 因此默认情况下app是找不到theme的.

* where QT theme saves

  ```
  system wide
  ---
  /usr/share/aurorea
  /usr/share/color-schemes
  /usr/share/plasma/desktoptheme
  /usr/share/plasma/look-and-feel
  
  user wide
  ---
  ~/.local/share/aurorae
  ~/.local/share/color-schemes
  ~/.local/share/plasma/desktoptheme
  ~/.local/share/plasma/look-and-feel
  
  icons (same with gtk)
  ---
  /usr/share/icons
  ~/.local/share/icons
  ```

  因此并不建议手动安装,package manager或专门的installer是更好的选择.对于我来说,虽然只是想给app一个theme而不需要其他的东西,但还是选择了用后者完整安装.

* how to apply QT theme

  前面提到`$DESKTOP_SESSION`与`$XDG_CURRENT_DESKTOP`,根据我搜索的结果,虽然将这些变量指定为kde或许能解决部分问题.但问题在于1.这需要拥有plasma桌面2.此环境变量可能导致一些app无法使用,譬如此处的clementine.

  真正的核心在于需要有一个部件去管理qt theme以让其正确apply.这就必须提到qt5ct了,其提供了图形化的style管理方式,而且的确能无冲突地解决问题.仅需要设置`QT_QPA_PLATFORMTHEME=qt5ct`来声明qt5ct来管理.

**`What did i do`**

1. Dependencies install

   ```sh
   $yay -S nordic-theme-git  # gtk theme
   $yay -S nordic-kde-git # qt theme(maybe not needed)
   $yay -S kvantum-theme-nordic-git # qt theme for kvantum
   $sudo pacman -S papirus-icon-theme # icon theme
   $yay -S qt5ct # controller
   $sudo pacman -S kvantum-qt5  # theme engine for qt
   $yay -S qt5-styleplugins # may helps
   
   $yay -S sddm-theme-sugar-candy-git # sddm theme (btw)
   ```

2. Configure gtk config

   ```ini
   ~/.config/gtk3.0/settings.ini
   ---
   gtk-theme-name=Nordic
   gtk-icon-theme-name=Papirus-Dark
   ...others you like
   ```

   or via lxappearance

3. Configure kvantum

    此处之所以在qt5ct前还选择kvantum是因为其能给窗口带来炫酷效果,此处仅仅显示了怎么选择,实际上还有很多配置项.

   ```sh
   $kvantummanager
   ...gui
   Select a theme: Nordic
   ```

4. Configure qt5ct

   ```sh
   $qt5ct
   ...gui
   Apperance-Style: kvantum-dark
   Icon-theme: Papirus-Dark
   ```

5. Set env variant

   add `export QT_QPA_PLATFORMTHEME=qt5ct` to the login script,e.g. bspwmrc
   
   <br><br>

### [App] dolphin

`@tl;dr: just a good-looking file manager`

[前面](#Apply gtk and qt themes to APPs)的目的之一就是在为dolphin做decoration.虽然终端下有更强大的file manager---ranger可以便捷化文件管理,但....或许是出于情怀吧.

<br>

<br>

### [About sudo] and npm 

**`intro.`**

在期望安装全局npm package时，我们需要使用`npm install -g`，但往往权限不足(默认安装到/usr下)，因此要搭配上`sudo`。而若所有的包管理器全然如此，那么便容易认为理所当然，但`yarn global`待给了我们不一样的结果。

`npm`和`yarn`对待global packages的理念是如此不同,以至于我们不得不去思考其利弊.显然可以这么理解:前者认为global应当于所有用户的所以project，而后者认为仅对于单个用户的所有project。

若是从这一角度出发,那么对于我们而言,yarn的理念是更符合实际情况的.不过还可以从另一个角度出发,也就是说sudo的角度.

普遍的使用sudo来配合npm的情况是，`if something doesn‘t work，try it with sudo.`。但实际上，sudo并非所有问题的解答方案。`npm install -g`便是一个例子。root(sudo)之所以拥有特权，在于其承担了相应的责任。若是无视责任而滥用权利，那么这绝非`sudo`的使用方法。换句话说,npm的package是开放的,若是不明不白地将某一个package安装成为系统级(global)其中的风险是相当大的.

应当遵循的原则是，仅仅在明确知晓指令将做什么时方才使用sudo。

**所以最佳的实践方式应当是将global package安装到用户级而非系统级.**

**`npm -g at user wide`**

这涉及到几个方面:创建文件夹用于保存global packages; 指示npm知晓文件夹用以**存储**(npm -- prefix)， **检索**(shell -- NODE_PATH， MANPATH)， **执行**(shell -- PATH)

1. Create a directory for your global packages

```sh
mkdir "${HOME}/.npm-packages"
```

2. Reference this directory for future usage in your `.bashrc`/`.zshrc`:

```sh
NPM_PACKAGES="${HOME}/.npm-packages"
```

3. Indicate to `npm` where to store your globally installed package. In your `$HOME/.npmrc` file add:

```sh
prefix=${HOME}/.npm-packages
```

4. Ensure `node` will find them. Add the following to your `.bashrc`/`.zshrc`:

```sh
NODE_PATH="$NPM_PACKAGES/lib/node_modules:$NODE_PATH"
```

5. Ensure you'll find installed binaries and man pages. Add the following to your `.bashrc`/`.zshrc`:

```sh
PATH="$NPM_PACKAGES/bin:$PATH"
# Unset manpath so we can inherit from /etc/manpath via the `manpath`
unset MANPATH # delete if you already modified MANPATH elsewhere in your config
MANPATH="$NPM_PACKAGES/share/man:$(manpath)"
```

**`npm environment -- nvm`**

上面的步骤是相对多步的,不过若是采用安装到用户级的environment manager来处理,便会简便很多.

npm环境管理工具`nvm`,可以理解成python的venv. 其出发点在于解决nodejs版本问题(有些nodejs包需要特定nodejs版本),因此会在用户权限范围内创建各种独立的环境.这从另一个手段解决了npm -g的危机.

<br><br>

---

<br><br>

## Polybar

<br>

### brightness control 

`@nord-top  [module/backlight]`

屏幕亮度的控制着实有些意料之外地繁琐，这不仅表现在polybar module上，同时也关乎当前硬件下命令端的控制。

不过先摆结论：若显卡受`xorg-xbacklight`(dependency)支持，那么应当是比较轻松的。若不是，则需要一番功夫。

**`Sept1`**

首先遵照[@aid1090x/polybar-themes](https://github.com/adi1090x/polybar-themes#troubleshooting)给出的troubleshooting，这是相当有参考意义的：

> **`3. Brightness module is not working`**
>
> If the brightness module is not working on your system, Edit `modules.ini` & `bars.ini` files and...
>
> - Use `type = internal/xbacklight` and `card = intel_backlight`, if you're using an Intel GPU.
> - Use `type = internal/backlight` if you're using an AMD or Nvidia GPU.
> - look inside `/sys/class/backlight/` and find the card name for your system. (eg: `card = amdgpu_bl0`)

虽然intelGPU给定了card,但还是建议确定一下。

如果能正常使用鼠标滚轮控制，那么恭喜开箱即用。如果不是，只得继续。注：仅在intel上测试，其他理论可行。

如果intel无法使用 `type = internal/xbacklight`（这出现在iris Xe上），那么当改成 `type = internal/backlight`。

而若图标甚至没有显示，大概率是card不对而使得模块无法被检测。

**`Step2`**

使用`type = internal/backlight`来调整亮度本质上是在直接更改brightness文件，其路径为`/sys/class/backlight<your-vender>/bightness`，如果关注polybar的debug输出，应当能注意到`permission denied`,这是因为polybar企图直接修改只被root修改的brightness文件。这当如何？直接sudo polybar吗？这显然是不被允许的。sudo不是plan B。

合理的措施是：1.让该文件属于某个group， 2. 让自己加入这一group， 3. 让group对这个文件有写入权。

看起来不难，**但brightness文件每次重启都将被重新创建**这一点让问题有些棘手。但好在arch wiki给我们指出`udev rule`这条路。

> *udev* is a userspace system that enables the operating system administrator to register userspace handlers for events.

1. create group

   ```sh
   sudo groupadd brightness # or any name you like
   ```

2. add user to the group

   ```sh
   sudo usermod -a -G brightness {whoami}
   ```

3. set [udev rule](https://t.codebug.vip/questions-661087.htm)

   ```sh
   $vim /etc/udev/rules.d/backlight.rules
   
   ACTION=="add", SUBSYSTEM=="backlight", KERNEL=="intel_backlight(yours)", RUN+="/bin/chgrp brightness /sys/class/backlight/%k/brightness"
   
   ACTION=="add", SUBSYSTEM=="backlight", KERNEL=="intel_backlight(yours)", RUN+="/bin/chmod g+w /sys/class/backlight/%k/brightness"
   ```

<br><br>

### clipmenu

`@nord-top [module/clipmenu-widget]`

这是一个非刚需模块，不过若是plasma用户应当非常熟悉于panel上的剪切板图标（实际上输入法、win10都有所支持）。

此处要介绍的剪切版能同dmenu、rofi完美联动，因此外观兼容性也就不用考虑了，而且其所对应的软件十分轻量化。

widget是通过systemd来同clipmenu沟通的，因此需要手动创建一个system service。

1. Install [dependency](https://github.com/cdown/clipmenu)

   ```sh
   $ yay -S clipmenu # or other way
   ```

2. Create systemd service

   ```sh
   $ mkdir -p ~/.config/systemd/user
   $ vim ~/.config/systemd/user/clipmenu.servics
   ---
   [Unit]
   Description=Clipmenu daemon
   
   [Service]
   ExecStart=/usr/bin/clipmenud
   Restart=always
   RestartSec=500ms
   
   MemoryDenyWriteExecute=yes
   NoNewPrivileges=yes
   ProtectControlGroups=yes
   ProtectKernelTunables=yes
   RestrictRealtime=yes
   
   # We don't need to do any clean up, so if something hangs (borked xclip, etc),
   # it's going to stay that way. Just forcefully kill and get it over with.
   TimeoutStopSec=2
   
   [Install]
   WantedBy=default.target
   ```

3.  Enable the service

   ```sh
   $ systemd --user enable clipmenu
   ```

<br>

<br>

### daily-poem

`@tl;dr: display chinese poems`

我的polybar最初是借鉴于[Yucklys/polybar-nord-theme](https://github.com/Yucklys/polybar-nord-theme#daily-poem)的,而之所以为之吸引,很大部分原因要归结于daily-poem这个module.

虽然仅是个抓取内容的脚本,但这仍不失为一个很棒的脚本.因为这解决了用户自行借助**今日诗歌**Token来抓取的繁琐.

脚本daily-poem足有8M大小,由于已经封装好所以没能看见内容.兴许是一个nodejs封装的cli?
