# NixOS Dotfiles với Niri

Cấu hình NixOS đơn giản sử dụng Flakes với Niri Wayland compositor.

**[🇬🇧 English](../README.md)**

## Tính năng

- **Niri Compositor**: Compositor Wayland hiện đại
- **Môi trường lập trình**: Node.js, Python3, Go, Rust
- **Công cụ build**: GCC, CMake, GNU Make
- **Quản lý phiên bản**: Git, GitHub CLI
- **Container**: Docker
- **Trình soạn thảo**: Helix, Vim, VS Code
- **Trình duyệt**: Firefox, Chromium
- **Kiểm thử API**: Postman, Insomnia
- **Tiện ích**: fastfetch, htop, wget, curl
- **Terminal**: Ghostty, Alacritty

## Mục lục

- [Yêu cầu](#yêu-cầu)
- [Cài đặt](#cài-đặt)
- [Cấu hình mặc định](#cấu-hình-mặc-định)
- [Sau khi cài đặt](#sau-khi-cài-đặt)
- [Sử dụng](#sử-dụng)
- [Các tác vụ thường gặp](#các-tác-vụ-thường-gặp)
- [Khắc phục sự cố](#khắc-phục-sự-cố)
- [Cấu trúc](#cấu-trúc)
- [Tùy chỉnh](#tùy-chỉnh)

## Yêu cầu

Trước khi cài đặt, đảm bảo bạn có:

- Hệ điều hành NixOS đã cài đặt (khuyến nghị phiên bản 25.11 trở lên)
- Flakes đã được bật trong cấu hình NixOS
- Kết nối Internet để tải các gói
- Quyền sudo/root để cài đặt system-level

### Bật Flakes

Nếu bạn chưa bật flakes, thêm dòng sau vào `/etc/nixos/configuration.nix`:

```nix
{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
}
```

Sau đó rebuild lại hệ thống:

```bash
sudo nixos-rebuild switch
```

## Cài đặt

### Thiết lập nhanh (Khuyến nghị)

Sử dụng script tự động để cấu hình username, hostname và password:

```bash
# 1. Clone repository này
git clone https://github.com/willriver-dev/dotfiles.git
cd dotfiles

# 2. Chạy script thiết lập (sẽ tự động tạo hardware config)
./setup.sh

# 3. Làm theo hướng dẫn để cấu hình:
#    - Tên người dùng (mặc định: người dùng hiện tại)
#    - Hostname (mặc định: nixos)
#    - Mật khẩu (tùy chỉnh hoặc dùng mặc định 'nixos')

# 4. Build và chuyển sang cấu hình mới
sudo nixos-rebuild switch --flake .#default

# 5. Khởi động lại để áp dụng tất cả thay đổi
sudo reboot
```

Script thiết lập sẽ tự động:
- Cập nhật `flake.nix` với tên người dùng của bạn
- Cập nhật `example-configuration.nix` với hostname và username
- Tạo file `configuration.nix` cá nhân hóa với cài đặt của bạn
- Đặt mật khẩu đã được mã hóa an toàn (tùy chỉnh hoặc mặc định 'nixos')
- Tự động tạo `hardware-configuration.nix` cho hệ thống của bạn

### Phương pháp 1: Cài đặt System-Level (Thủ công)

Phương pháp này cài đặt cấu hình toàn hệ thống:

```bash
# 1. Clone repository này
git clone https://github.com/willriver-dev/dotfiles.git
cd dotfiles

# 2. Xem lại cấu hình (tùy chọn nhưng nên làm)
cat flake.nix
cat example-configuration.nix

# 3. Build và chuyển sang cấu hình mới
sudo nixos-rebuild switch --flake .#default

# 4. Khởi động lại để áp dụng tất cả thay đổi
sudo reboot
```

### Phương pháp 2: Home Manager (Chỉ User-Level)

Để cấu hình user-level mà không thay đổi system-level:

```bash
# 1. Clone repository này
git clone https://github.com/willriver-dev/dotfiles.git
cd dotfiles

# 2. Build cấu hình home-manager
nix build .#homeConfigurations.default.activationPackage

# 3. Kích hoạt cấu hình
./result/activate
```

**Lưu ý**: Phương pháp này không bao gồm Docker và Niri compositor (tính năng system-level).

### Phương pháp 3: Tích hợp với cấu hình NixOS hiện có

Nếu bạn đã có cấu hình NixOS, bạn có thể tích hợp flake này:

1. Thêm flake này như một input trong `flake.nix` của hệ thống:

```nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    dotfiles.url = "github:willriver-dev/dotfiles";
  };
}
```

2. Import và sử dụng các gói trong cấu hình:

```nix
environment.systemPackages = dotfiles.packages.${system};
```

Xem `example-configuration.nix` để biết ví dụ đầy đủ.

## Cấu hình mặc định

### User mặc định

- **Tên user**: `user`
- **Thư mục home**: `/home/user`
- **Nhóm**: `wheel`, `docker`, `networkmanager`

**Quan trọng**: Tên user mặc định là `user`. Bạn nên thay đổi để khớp với tên user thực tế của mình.

### Hostname mặc định

- **Hostname**: `nixos` (như trong `example-configuration.nix`)

Bạn có thể thay đổi hostname bằng cách sửa `/etc/nixos/configuration.nix` hoặc sửa trong cấu hình flake.

### Phiên bản System State

- **State Version**: `25.11`

Đây là phiên bản NixOS 25.11. Giữ nguyên để khớp với phiên bản NixOS của bạn.

## Sau khi cài đặt

### 1. Đặt mật khẩu cho User

Sau khi cài đặt, bạn **phải** đặt mật khẩu cho user:

```bash
# Đặt mật khẩu cho tài khoản 'user' mặc định
sudo passwd user

# Hoặc cho username tùy chỉnh của bạn
sudo passwd your-username
```

**Lưu ý bảo mật**: Luôn đặt mật khẩu mạnh ngay sau khi cài đặt!

### 2. Cấu hình User của bạn

Nếu bạn không sử dụng tên user mặc định `user`, hãy cập nhật cấu hình:

1. Sửa `flake.nix` và thay đổi dòng 86:

```nix
username = "ten-user-thuc-te-cua-ban";
```

2. Cập nhật cấu hình hệ thống để tạo user của bạn:

```nix
users.users.ten-user-cua-ban = {
  isNormalUser = true;
  extraGroups = [ "wheel" "docker" "networkmanager" ];
};
```

3. Rebuild hệ thống:

```bash
sudo nixos-rebuild switch --flake .#default
```

### 3. Cấu hình Hostname (Tùy chọn)

Để thay đổi hostname:

1. Sửa `/etc/nixos/configuration.nix`:

```nix
networking.hostName = "hostname-cua-ban";
```

2. Rebuild:

```bash
sudo nixos-rebuild switch
```

### 4. Thêm User vào nhóm Docker

Nếu Docker không hoạt động, đảm bảo user của bạn trong nhóm docker:

```bash
sudo usermod -aG docker $USER
```

Sau đó đăng xuất và đăng nhập lại để thay đổi có hiệu lực.

### 5. Cấu hình Niri Compositor

Sau khi khởi động lại, bạn có thể chọn Niri như compositor trong display manager. Nếu cần cấu hình Niri:

```bash
# Cấu hình Niri thường ở:
# ~/.config/niri/config.kdl
```

## Sử dụng

### Khởi động Niri

Nếu bạn cài đặt system-wide và đã khởi động lại:

1. Ở màn hình đăng nhập, chọn "Niri" làm session
2. Đăng nhập bằng username và password
3. Niri sẽ tự động khởi động

### Sử dụng cấu hình Home Manager

Nếu bạn dùng Phương pháp 2 (Home Manager):

```bash
# Điều hướng đến thư mục dotfiles
cd ~/dotfiles

# Rebuild và kích hoạt
nix build .#homeConfigurations.default.activationPackage
./result/activate
```

### Truy cập ứng dụng

Sau khi cài đặt, tất cả ứng dụng đều có sẵn trong hệ thống:

```bash
# Mở terminal
ghostty  # hoặc alacritty

# Soạn thảo văn bản
helix filename.txt
vim filename.txt
code .  # VS Code

# Trình duyệt
firefox
chromium

# Công cụ phát triển
node --version
python3 --version
go version
rustc --version

# Thông tin hệ thống
fastfetch
htop

# Thao tác Git
git status
gh repo list
```

## Các tác vụ thường gặp

### Cập nhật cấu hình

Khi bạn thay đổi `flake.nix`:

```bash
cd ~/dotfiles
sudo nixos-rebuild switch --flake .#default
```

### Thêm gói mới

1. Sửa `flake.nix`
2. Thêm gói vào danh sách `commonPackages` (khoảng dòng 19)
3. Rebuild:

```bash
sudo nixos-rebuild switch --flake .#default
```

### Cập nhật tất cả gói

```bash
cd ~/dotfiles

# Cập nhật flake inputs
nix flake update

# Rebuild với các gói đã cập nhật
sudo nixos-rebuild switch --flake .#default
```

### Xóa gói

1. Sửa `flake.nix`
2. Xóa gói khỏi `commonPackages`
3. Rebuild:

```bash
sudo nixos-rebuild switch --flake .#default
```

### Kiểm tra thông tin hệ thống

```bash
# Thông tin hệ thống
fastfetch

# Phiên bản NixOS
nixos-version

# Các gói đã cài
nix-env -q

# Tài nguyên hệ thống
htop
```

### Làm việc với Docker

```bash
# Kiểm tra trạng thái Docker
sudo systemctl status docker

# Chạy container
docker run hello-world

# Liệt kê container đang chạy
docker ps

# Liệt kê tất cả container
docker ps -a
```

## Khắc phục sự cố

### Vấn đề: "command not found" cho các gói đã cài

**Giải pháp**: Đăng xuất và đăng nhập lại, hoặc source profile:

```bash
source /etc/profile
```

### Vấn đề: Docker permission denied

**Giải pháp**: Thêm user vào nhóm docker:

```bash
sudo usermod -aG docker $USER
```

Sau đó đăng xuất và đăng nhập lại.

### Vấn đề: Niri không khởi động

**Giải pháp**:

1. Kiểm tra Niri có được bật không:
   ```bash
   systemctl status niri
   ```

2. Kiểm tra các file session Xorg/Wayland:
   ```bash
   ls /usr/share/wayland-sessions/
   ```

3. Thử khởi động Niri thủ công:
   ```bash
   niri
   ```

4. Kiểm tra logs:
   ```bash
   journalctl -u display-manager
   ```

### Vấn đề: Flakes không hoạt động

**Giải pháp**: Đảm bảo flakes được bật trong `/etc/nixos/configuration.nix`:

```nix
nix.settings.experimental-features = [ "nix-command" "flakes" ];
```

### Vấn đề: Build thất bại với "error: getting status of '/nix/store/...': No such file or directory"

**Giải pháp**:

1. Dọn dẹp và thử lại:
   ```bash
   nix-collect-garbage
   sudo nixos-rebuild switch --flake .#default
   ```

2. Cập nhật flake lock:
   ```bash
   nix flake update
   ```

### Vấn đề: Hết dung lượng đĩa

**Giải pháp**: Xóa các generation cũ và garbage collect:

```bash
# Liệt kê các generation
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system

# Xóa generation cũ (giữ 3 gần nhất)
sudo nix-env --delete-generations +3 --profile /nix/var/nix/profiles/system

# Garbage collect
sudo nix-collect-garbage -d

# Hoặc làm tất cả cùng lúc
sudo nix-collect-garbage --delete-older-than 7d
```

### Vấn đề: Gói không có sẵn

**Giải pháp**: Gói có thể không có trong nixpkgs. Tìm kiếm:

```bash
# Tìm kiếm gói
nix search nixpkgs ten-goi

# Kiểm tra trong unstable
nix search nixpkgs#ten-goi
```

### Vấn đề: Lỗi cấu hình

**Giải pháp**: Test cấu hình trước khi switch:

```bash
# Test build mà không kích hoạt
sudo nixos-rebuild test --flake .#default

# Hoặc chỉ build
sudo nixos-rebuild build --flake .#default
```

### Nhận trợ giúp

Nếu bạn vẫn gặp vấn đề:

1. Xem tài liệu NixOS: https://nixos.org/manual/nixos/stable/
2. Truy cập NixOS Discourse: https://discourse.nixos.org/
3. Xem tài liệu Niri: https://github.com/YaLTeR/niri
4. Mở issue trên repository này: https://github.com/willriver-dev/dotfiles/issues

## Cấu trúc

```
dotfiles/
├── flake.nix                    # Cấu hình chính với các gói và Niri
├── example-configuration.nix    # Ví dụ cấu hình hệ thống NixOS
├── setup.sh                     # Script thiết lập tự động (MỚI!)
├── README.md                    # Tài liệu tiếng Anh
└── docs/
    └── README.vi-VN.md         # Tài liệu tiếng Việt (file này)
```

Script `setup.sh` tự động hóa quá trình cấu hình thủ công tẻ nhạt. Thay vì phải chỉnh sửa file để đặt username, hostname và password, chỉ cần chạy script và trả lời vài câu hỏi!

## Tùy chỉnh

### Sửa đổi các gói

Sửa `flake.nix` khoảng dòng 19-58 để thêm hoặc xóa gói khỏi danh sách `commonPackages`:

```nix
commonPackages = with pkgs; [
  # Thêm gói của bạn ở đây
  neovim
  tmux
  # ...
];
```

### Tùy chỉnh Niri

Sửa phần Niri trong `flake.nix` (khoảng dòng 67):

```nix
programs.niri.enable = true;
# Thêm cấu hình Niri khác ở đây
```

### Thay đổi cài đặt hệ thống

Sửa phần cấu hình hệ thống trong `flake.nix` hoặc sử dụng `example-configuration.nix` làm mẫu cho `/etc/nixos/configuration.nix` của bạn.

### Sử dụng phiên bản NixOS khác

Trong `flake.nix`, thay đổi nixpkgs input (dòng 5):

```nix
nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";  # hoặc phiên bản khác
```

Sau đó update:

```bash
nix flake update
sudo nixos-rebuild switch --flake .#default
```

## Giấy phép

Cấu hình này được cung cấp như-là để sử dụng cá nhân. Vui lòng fork và sửa đổi theo nhu cầu của bạn.

## Đóng góp

Chúng tôi hoan nghênh đóng góp! Vui lòng mở issue hoặc pull request.
