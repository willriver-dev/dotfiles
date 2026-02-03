# Hướng dẫn nhanh - Quick Start Guide

## 🇻🇳 Tiếng Việt

### Câu hỏi: Dùng file nào để chạy? `example-configuration.nix` hay `configuration.nix`?

**Trả lời**: Sử dụng `configuration.nix` (không phải `example-configuration.nix`).

- **`configuration.nix`**: Đây là file bạn cần để chạy. File này chứa cấu hình thực tế của hệ thống.
- **`example-configuration.nix`**: Chỉ là ví dụ tham khảo, KHÔNG được sử dụng bởi flake.

### Cách chạy cấu hình

#### Bước 1: Tạo các file cấu hình (nếu chưa có)

```bash
cd ~/dotfiles
./setup.sh
```

Script này sẽ tự động tạo:
- `configuration.nix` - với username, hostname, password của bạn
- `hardware-configuration.nix` - cấu hình phần cứng của máy bạn

#### Bước 2: Rebuild hệ thống

```bash
sudo nixos-rebuild switch --flake .#default
```

#### Bước 3: Reboot

```bash
sudo reboot
```

### Khắc phục lỗi "requires boot.loader.grub.device"

Nếu bạn gặp lỗi này khi chạy `nixos-rebuild`:

```
Failed assertions:
- The filesystem option does not specify your root file system...
```

**Nguyên nhân**: Thiếu file `configuration.nix` hoặc `hardware-configuration.nix`

**Giải pháp**:

```bash
# Chạy script setup để tạo các file cần thiết
./setup.sh

# Sau đó rebuild lại
sudo nixos-rebuild switch --flake .#default
```

### Về phiên bản 25.11

Tất cả các file đã được cập nhật lên phiên bản 25.11:
- ✅ `flake.nix` - nixpkgs: 25.11, home-manager: 25.11
- ✅ `configuration.nix` - system.stateVersion: 25.11
- ✅ `example-configuration.nix` - system.stateVersion: 25.11
- ✅ `setup.sh` - mặc định: 25.11

### Tóm tắt

1. **Chạy `./setup.sh`** để tạo `configuration.nix` và `hardware-configuration.nix`
2. **Chạy `sudo nixos-rebuild switch --flake .#default`** để áp dụng cấu hình
3. **Reboot** để hoàn tất

---

## 🇬🇧 English

### Question: Which file to use? `example-configuration.nix` or `configuration.nix`?

**Answer**: Use `configuration.nix` (not `example-configuration.nix`).

- **`configuration.nix`**: This is the file you need to run. It contains your actual system configuration.
- **`example-configuration.nix`**: Just a reference example, NOT used by the flake.

### How to run the configuration

#### Step 1: Generate configuration files (if not exists)

```bash
cd ~/dotfiles
./setup.sh
```

This script will automatically create:
- `configuration.nix` - with your username, hostname, password
- `hardware-configuration.nix` - your machine's hardware config

#### Step 2: Rebuild the system

```bash
sudo nixos-rebuild switch --flake .#default
```

#### Step 3: Reboot

```bash
sudo reboot
```

### Fix "requires boot.loader.grub.device" error

If you get this error when running `nixos-rebuild`:

```
Failed assertions:
- The filesystem option does not specify your root file system...
```

**Cause**: Missing `configuration.nix` or `hardware-configuration.nix` files

**Solution**:

```bash
# Run setup script to generate required files
./setup.sh

# Then rebuild
sudo nixos-rebuild switch --flake .#default
```

### About version 25.11

All files have been updated to version 25.11:
- ✅ `flake.nix` - nixpkgs: 25.11, home-manager: 25.11
- ✅ `configuration.nix` - system.stateVersion: 25.11
- ✅ `example-configuration.nix` - system.stateVersion: 25.11
- ✅ `setup.sh` - default: 25.11

### Summary

1. **Run `./setup.sh`** to create `configuration.nix` and `hardware-configuration.nix`
2. **Run `sudo nixos-rebuild switch --flake .#default`** to apply configuration
3. **Reboot** to complete
