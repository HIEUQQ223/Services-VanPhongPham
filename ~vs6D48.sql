CREATE DATABASE QuanLy_VanPhongPham1;
GO
USE QuanLy_VanPhongPham1;
GO

-- Bảng danh mục sản phẩm
CREATE TABLE DanhMucSanPham (
  MaDanhMuc INT PRIMARY KEY,
  TenDanhMuc NVARCHAR(50) NOT NULL
);

CREATE TABLE LoaiTaiKhoan (
  MaLoaiTaiKhoan INT PRIMARY KEY IDENTITY(1,1),
  TenLoaiTaiKhoan NVARCHAR(50) NOT NULL,
  MoTa NVARCHAR(255),
  TrangThai BIT NOT NULL DEFAULT 1
);

CREATE TABLE ThongTinTaiKhoan (
  MaTaiKhoan INT PRIMARY KEY IDENTITY(1,1),  
  Email VARCHAR(255) UNIQUE NOT NULL,
  MatKhau VARCHAR(255) NOT NULL,
  TenNguoiDung NVARCHAR(255),
  GioiTinh NVARCHAR(10),
  SoDienThoai VARCHAR(20),
  MaLoaiTaiKhoan INT NOT NULL DEFAULT 1, 
  TrangThai BIT NOT NULL DEFAULT 1,
  FOREIGN KEY (MaLoaiTaiKhoan) REFERENCES LoaiTaiKhoan(MaLoaiTaiKhoan)
);

-- Bảng địa chỉ giao hàng
CREATE TABLE DiaChiGiaoHang (
  MaDiaChi INT PRIMARY KEY IDENTITY(1,1),
  MaTaiKhoan INT NOT NULL,
  TenNguoiNhan NVARCHAR(255) NOT NULL,
  SoDienThoai VARCHAR(20) NOT NULL,
  DiaChiChiTiet NVARCHAR(500) NOT NULL,
  TrangThai BIT NOT NULL DEFAULT 1,
  FOREIGN KEY (MaTaiKhoan) REFERENCES ThongTinTaiKhoan(MaTaiKhoan)
);

-- Bảng khuyến mãi
CREATE TABLE KhuyenMai (
  MaKhuyenMai INT PRIMARY KEY IDENTITY(1,1),
  TenKhuyenMai NVARCHAR(255) NOT NULL,
  NgayBatDau DATE,
  NgayKetThuc DATE,
  PhanTramGiam INT,
  MoTaKhuyenMai NVARCHAR(MAX),
  TrangThai INT DEFAULT 1
);

-- Bảng sản phẩm
CREATE TABLE SanPham (
  MaSanPham INT PRIMARY KEY IDENTITY(1,1),
  TenSanPham NVARCHAR(255) NOT NULL,
  LoaiSanPham NVARCHAR(255),
  ThuongHieu NVARCHAR(255),
  MoTa NVARCHAR(MAX),
  XuatXu NVARCHAR(255),
  GiaTien DECIMAL(10, 2),
  SoLuong INT DEFAULT 0,
  HinhAnh NVARCHAR(255),
  TrangThai INT DEFAULT 1,
  MaDanhMuc INT,
  FOREIGN KEY (MaDanhMuc) REFERENCES DanhMucSanPham(MaDanhMuc)
);

-- Bảng đơn hàng
CREATE TABLE DonHang (
  MaDonHang INT PRIMARY KEY IDENTITY(1,1),
  MaTaiKhoan INT NOT NULL,
  NgayDatHang DATETIME NOT NULL DEFAULT GETDATE(),
  TongTienTruocGiam DECIMAL(10, 2) NOT NULL,
  TongTienSauKhiGiam DECIMAL(10, 2) NOT NULL,
  MaKhuyenMai INT,
  TrangThaiDonHang INT NOT NULL DEFAULT 1, -- 1: Chờ xử lý, 2: Đã xác nhận, 3: Đang giao, 4: Hoàn thành, 5: Đã hủy
  MaDiaChi INT NOT NULL, -- Liên kết với bảng địa chỉ giao hàng
  HinhThucThanhToan INT NOT NULL, -- Hình thức thanh toán
  GhiChu NVARCHAR(MAX),
  NgayCapNhat DATETIME DEFAULT GETDATE(),
  FOREIGN KEY (MaTaiKhoan) REFERENCES ThongTinTaiKhoan(MaTaiKhoan),
  FOREIGN KEY (MaKhuyenMai) REFERENCES KhuyenMai(MaKhuyenMai),
  FOREIGN KEY (MaDiaChi) REFERENCES DiaChiGiaoHang(MaDiaChi)
);

-- Bảng chi tiết đơn hàng
CREATE TABLE ChiTietDonHang (
  MaDonHang INT NOT NULL,
  MaSanPham INT NOT NULL,
  SoLuong INT NOT NULL,
  GiaBan DECIMAL(10, 2) NOT NULL,
  ThanhTien AS (SoLuong * GiaBan) PERSISTED,
  GhiChu NVARCHAR(MAX),
  PRIMARY KEY (MaDonHang, MaSanPham),
  FOREIGN KEY (MaDonHang) REFERENCES DonHang(MaDonHang),
  FOREIGN KEY (MaSanPham) REFERENCES SanPham(MaSanPham)
);

-- Bảng phiếu nhập
CREATE TABLE PhieuNhap (
    MaPhieuNhap INT PRIMARY KEY IDENTITY(1,1),
    NgayNhap DATETIME NOT NULL DEFAULT GETDATE(),
    TongSoLuong INT DEFAULT 0,
    TongTienHang DECIMAL(10, 2) DEFAULT 0,
    GhiChu NVARCHAR(MAX),
    TrangThai INT NOT NULL DEFAULT 1,
    MaTaiKhoan INT NOT NULL, -- Người tạo phiếu nhập (bắt buộc)
    FOREIGN KEY (MaTaiKhoan) REFERENCES ThongTinTaiKhoan(MaTaiKhoan)
);

-- Bảng chi tiết phiếu nhập
CREATE TABLE ChiTietPhieuNhap (
    MaPhieuNhap INT NOT NULL,
    MaSanPham INT NOT NULL,
    SoLuong INT NOT NULL,
    GiaNhap DECIMAL(10, 2) NOT NULL,
    ThanhTien AS (SoLuong * GiaNhap) PERSISTED,
    GhiChu NVARCHAR(MAX),
    TrangThai INT NOT NULL DEFAULT 1,
    PRIMARY KEY (MaPhieuNhap, MaSanPham),
    FOREIGN KEY (MaPhieuNhap) REFERENCES PhieuNhap(MaPhieuNhap),
    FOREIGN KEY (MaSanPham) REFERENCES SanPham(MaSanPham)
);

-- Dữ liệu mẫu
INSERT INTO DanhMucSanPham (MaDanhMuc, TenDanhMuc) VALUES
(1, N'Giấy In Ấn Pho-To'),
(2, N'Bìa-Kệ-Rổ'),
(3, N'Đụng cụ văn phòng chất lượng '),
(4, N'Sổ-Tập-Bao Thư'),
(5, N'Bút mực chất lượng cao'),
(6, N'Băng keo - Dao- Kéo');

-- Dữ liệu mẫu cho loại tài khoản
INSERT INTO LoaiTaiKhoan (TenLoaiTaiKhoan, MoTa)
VALUES 
(N'ADMIN', N'Tài khoản quản trị hệ thống'),
(N'KHACHHANG', N'Tài khoản người dùng mua hàng');

INSERT INTO ThongTinTaiKhoan (Email, MatKhau, MaLoaiTaiKhoan, TenNguoiDung, GioiTinh, SoDienThoai, TrangThai) VALUES
('admin@vanphongpham.com', 'admin123', 1, N'Quản trị viên', NULL, '0123456789', 1),
('khachhang1@email.com', 'kh001123', 2, N'Nguyễn Văn An', N'Nam', '0901234567', 1),
('khachhang2@email.com', 'kh002123', 2, N'Trần Thị Bình', N'Nữ', '0912345678', 1),
('khachhang3@email.com', 'kh003123', 2, N'Lê Văn Cường', N'Nam', '0923456789', 1);


-- Địa chỉ giao hàng
INSERT INTO DiaChiGiaoHang (MaTaiKhoan, TenNguoiNhan, SoDienThoai, DiaChiChiTiet, TrangThai) VALUES
(2, N'Nguyễn Văn An', '0901234567', N'123 Nguyễn Văn Cừ, Q.5, TP.HCM', 1),
(2, N'Nguyễn Văn An', '0901234567', N'456 Lê Lợi, Q.1, TP.HCM', 1),
(3, N'Trần Thị Bình', '0912345678', N'456 Lê Văn Sỹ, Q.3, TP.HCM', 1),
(4, N'Lê Văn Cường', '0923456789', N'789 Võ Văn Tần, Q.1, TP.HCM', 1);
INSERT INTO SanPham (TenSanPham, LoaiSanPham, ThuongHieu, MoTa, XuatXu, GiaTien, SoLuong, HinhAnh, TrangThai, MaDanhMuc) VALUES
-- Bút viết các loại
(N'Bút bi Flexoffice FO-036', N'Bút viết', 'Flexoffice', N'Bút bi cao cấp, mực đen, thân nhựa chắc chắn, đạt tiêu chuẩn châu Âu.', N'Việt Nam', 5000, 150, 'https://product.hstatic.net/1000230347/product/but_bi_flexoffice_fo-036_d04ed7423ba245738192e64e601e2cae.jpg', 1, 1),
(N'Bút gel Thiên Long Flexoffice FO-GELB014', N'Bút viết', 'Flexoffice', N'Bút gel mực xanh, viết trơn êm, thiết kế hiện đại.', N'Việt Nam', 6000, 120, 'https://product.hstatic.net/1000230347/product/fo-gelb014_ff1072e935d14b8e83a7ee671826b7b3.jpg', 1, 1),
(N'Bút chì bấm Neon Colokit PC-C002', N'Bút viết', 'Colokit', N'Thiết kế neon bắt mắt, bút chắc tay, thích hợp học sinh.', N'Việt Nam', 8000, 150, 'https://product.hstatic.net/1000230347/product/artboard_1_copy_472c9ba38a7c46369b92e74e05840c26.jpg', 1, 1),
(N'Bút xóa kéo Thiên Long CP-20', N'Bút viết', 'Thiên Long', N'Xóa sạch, khô nhanh, có thể viết lại ngay.', N'Việt Nam', 10000, 90, 'https://product.hstatic.net/1000230347/product/artboard_1_copy_59abe579daed4518be12fce79721f9b9.jpg', 1, 1),
(N'Bút xóa nước Thiên Long CP-015', N'Bút viết', 'Thiên Long', N'Mực trắng che lỗi nhanh, dễ sử dụng, không lem.', N'Việt Nam', 12000, 80, 'https://product.hstatic.net/1000230347/product/img_9577_cfcc94c142284b819e3a0b42c3e8dbe3.jpg', 1, 1),
(N'Bút xóa kéo FlexOffice FO-CT02 (Màu ngẫu nhiên)', N'Bút viết', 'Flexoffice', N'Bút xóa tiện dụng, thiết kế ergonomic, màu sắc ngẫu nhiên.', N'Việt Nam', 8000, 60, 'https://product.hstatic.net/1000230347/product/artboard_1_copy_921dc8eae0514832aa260403faf6c347.jpg', 1, 1),
-- Bút màu và phụ kiện
(N'Hộp 5 bút dạ quang pastel HL-019/DS - Demon Slayer', N'Bút màu', 'Thiên Long', N'Thiết kế 5 màu pastel, phong cách Demon Slayer nổi bật.', N'Việt Nam', 45000, 60, 'https://product.hstatic.net/1000230347/product/artboard_1_copy_de1d7800386a4c1b8684b4525957d257.jpg', 1, 1),
(N'Bút lông 12 màu bấm Colokit - 0.6mm', N'Bút màu', 'Colokit', N'Bút lông màu tiện lợi, dễ sử dụng cho học sinh tiểu học.', N'Trung Quốc', 25000, 80, 'https://product.hstatic.net/1000230347/product/artboard_1_copy_a7a70284dd424d75bd7942a99f20a223.jpg', 1, 4),
(N'Bút lông 20 màu Pastel Fiber Pen Thiên Long Colokit SWM-C008', N'Bút màu', 'Colokit', N'Hộp 20 bút màu pastel an toàn cho học sinh, màu sắc rực rỡ, có thể rửa được.', N'Việt Nam', 36000, 45, 'https://product.hstatic.net/1000230347/product/artboard_2_copy_0d340aa0075740a48d08c59c1892f121.jpg', 1, 4),
(N'Combo 5 Bút lông dầu FO-PM-011', N'Bút màu', 'Flexoffice', N'Mực bền màu, viết tốt trên nhiều bề mặt.', N'Việt Nam', 45000, 40, 'https://product.hstatic.net/1000230347/product/42sf_5208f6eabe7a4b84b1b91572c6cadad0.jpg', 1, 1),
(N'Mực bút lông dầu PMI-01', N'Mực viết', 'Thiên Long', N'Mực dành cho bút lông dầu, màu sắc đậm, nhanh khô.', N'Việt Nam', 20000, 50, 'https://product.hstatic.net/1000230347/product/artboard_1_copy_edc9d80962b340d69561f2e904e45a55.jpg', 1, 1),
-- Dụng cụ văn phòng
(N'Keo dán UHU Stick 21g', N'Dụng cụ văn phòng', 'UHU', N'Keo dán đa năng, tiện lợi, dán nhanh, không độc hại.', N'Đức', 20000, 100, 'https://www.uhu.com/getoptimizedimage/b5a79747-a627-417f-9fe4-857ad5d29eef/4026700341201-34121-DEFAULT?siteName=Uhu&width=740&height=249', 1, 3),
(N'Dao rọc giấy Thiên Long có khóa an toàn', N'Dụng cụ văn phòng', 'Thiên Long', N'Dao rọc giấy thông minh, chắc chắn, khóa tự động an toàn.', N'Việt Nam', 15000, 70, 'https://product.hstatic.net/1000230347/product/drg_ko_logo_94e9836f400c4ee7be1df892d19ad5ad.png', 1, 3),
(N'Kéo văn phòng Thiên Long', N'Dụng cụ văn phòng', 'Thiên Long', N'Kéo chịu lực, tay cầm chắc chắn, cắt giấy dễ dàng.', N'Việt Nam', 18000, 70, 'https://product.hstatic.net/1000230347/product/thumb_khong_logo_a321f2e3a9794f67a98bb374b16f0aac.jpg', 1, 3),
(N'Kéo Thiên Long SC-015', N'Dụng cụ văn phòng', 'Thiên Long', N'Kéo thép không gỉ, thiết kế tiện dụng, tay cầm êm ái.', N'Việt Nam', 22000, 60, 'https://product.hstatic.net/1000230347/product/54dghg_a628969e2a1e42509235c85c184a20ea.jpg', 1, 3),
(N'Kéo Flexoffice FO-SC01', N'Dụng cụ văn phòng', 'Flexoffice', N'Kéo văn phòng chất lượng cao, lưỡi sắc bén, thiết kế tiện dụng.', N'Việt Nam', 25000, 60, 'https://product.hstatic.net/1000230347/product/43276_c384e10ddc774aa69cd948be742a12b4.jpg', 1, 3),
(N'Kéo Flexoffice FO-SC02', N'Dụng cụ văn phòng', 'Flexoffice', N'Kéo inox cao cấp, tay cầm chống trượt, cắt chính xác.', N'Việt Nam', 28000, 60, 'https://product.hstatic.net/1000230347/product/32sdf_1e757acbae924ef4843198bf545a80de.jpg', 1, 3),
(N'Bộ sản phẩm bấm kim Thiên Long STAPLER KIT 02', N'Dụng cụ văn phòng', 'Thiên Long', N'Bộ bấm kim kèm kim bấm, nhỏ gọn, phù hợp học sinh – văn phòng.', N'Việt Nam', 22000, 40, 'https://down-vn.img.susercontent.com/file/5808d91c9cf0fd6a7c51ae3c7718f288.webp', 1, 3),
(N'Bấm kim đại FO-BS01', N'Dụng cụ văn phòng', 'Flexoffice', N'Thiết kế bền chắc, dễ sử dụng, thích hợp văn phòng.', N'Việt Nam', 30000, 60, 'https://product.hstatic.net/1000230347/product/fo-bs01_42d49513505341c6816fe6f54c285783.jpg', 1, 3),
(N'Bộ bấm kim và kim FO-ST03-S2', N'Dụng cụ văn phòng', 'Flexoffice', N'Bộ sản phẩm bấm kim và kim chất lượng cao.', N'Việt Nam', 35000, 60, 'https://product.hstatic.net/1000230347/product/set_bam_kim_kim_bam_fo_st03_s2_07_a37e0eb6e6b943b88f0a437b3c601250.jpg', 1, 3),
(N'Giấy note dán màu vàng 3x3', N'Dụng cụ văn phòng', '3M', N'Giấy ghi chú màu vàng, dán dính nhẹ, không để lại keo.', N'Mỹ', 8500, 90, 'https://anlocviet.com/wp-content/uploads/Giay-note-vang-3x3-Pronoti-an-loc-viet.jpg', 1, 3),
-- Bìa hồ sơ
(N'Bìa hồ sơ 20 lá màu Pastel FO-DB007/NĐ', N'Bìa hồ sơ', 'Flexoffice', N'Bìa nhựa PP đẹp mắt, chứa được 20 tờ, chống ẩm, tiện lợi.', N'Việt Nam', 17000, 100, 'https://product.hstatic.net/1000230347/product/423qdas_370b0d4af4fe4f69a4a1133b3fc2c9ef.jpg', 1, 3),
(N'Bìa lá A4 Flexoffice FO-CH012', N'Bìa hồ sơ', 'Flexoffice', N'Bìa lá A4 chất lượng, bảo vệ tài liệu hiệu quả.', N'Việt Nam', 12000, 60, 'https://product.hstatic.net/1000230347/product/12fs_f9779c20823d48729a4a7d174204495d.jpg', 1, 3),
(N'Bìa lá A4 Flexoffice FO-CH03', N'Bìa hồ sơ', 'Flexoffice', N'Bìa lá A4 trong suốt, dễ nhận diện nội dung.', N'Việt Nam', 10000, 60, 'https://product.hstatic.net/1000230347/product/45dsfs_481eb9e6f53340d0ab7c49b39e3366b0.jpg', 1, 3),
(N'Bìa Acco A4 Thiên Long Flexoffice FO-PPFFA4', N'Bìa hồ sơ', 'Flexoffice', N'Bìa acco chất lượng cao, phù hợp lưu trữ tài liệu quan trọng.', N'Việt Nam', 15000, 60, 'https://product.hstatic.net/1000230347/product/sdacxz_61c87024881a49319f9747329e6cf432.jpg', 1, 3),
(N'Bìa Report File A4 Flexoffice FO-RFA4', N'Bìa hồ sơ', 'Flexoffice', N'Bìa report file chuyên dụng cho báo cáo và tài liệu.', N'Việt Nam', 18000, 60, 'https://product.hstatic.net/1000230347/product/246__3_.jpg', 1, 3),
(N'Bìa 20 lá A4 Flexoffice FO-DB01', N'Bìa hồ sơ', 'Flexoffice', N'Bìa đựng tài liệu 20 lá, thiết kế gọn nhẹ.', N'Việt Nam', 20000, 60, 'https://product.hstatic.net/1000230347/product/fo-db01_ko_logo_ee4054919b824400882e63299e0ece9a.jpg', 1, 3),
(N'Bìa 40 lá A4 Flexoffice FO-DB02', N'Bìa hồ sơ', 'Flexoffice', N'Bìa đựng tài liệu 40 lá, dung lượng lớn tiện lợi.', N'Việt Nam', 25000, 60, 'https://product.hstatic.net/1000230347/product/765fd_37099fac12f34823aa83278b3d8b5bef.jpg', 1, 3),
-- Giấy in và sổ tay
(N'Giấy A4 Double A 70gsm (500 tờ)', N'Giấy in', 'Double A', N'Giấy in chất lượng cao, độ trắng sáng tốt, không kẹt giấy.', N'Thái Lan', 95000, 300, 'https://vppdeli.vn/wp-content/uploads/2024/03/double-a-70gsm.png', 1, 4),
(N'Sổ Tay Campus Tiếng Anh 8', N'Sổ tay', 'Campus', N'Sổ tay học tiếng Anh lớp 8, giấy dày đẹp, phù hợp học sinh.', N'Trung Quốc', 25000, 80, 'https://product.hstatic.net/1000230347/product/upload_0114160ca1ee4273ae5c7186d088fac0.jpg', 1, 4),
(N'Sổ lò xo A5 Thiên Long MB-025', N'Sổ tay', 'Thiên Long', N'Sổ lò xo dòng kẻ 7mm, giấy trắng mịn, phù hợp ghi chép.', N'Việt Nam', 20000, 50, 'https://product.hstatic.net/1000230347/product/artboard_1_copy_b51030e930dc4aed94bcfb43ed9c0427.jpg', 1, 4),
(N'Sổ lò xo Demon Slayer MB-023/DS', N'Sổ tay', 'Thiên Long', N'Sổ thiết kế nhân vật anime Demon Slayer, phù hợp học sinh.', N'Việt Nam', 28000, 40, 'https://product.hstatic.net/1000230347/product/artboard_1_copy_de368a71d2e54ea5a217bdcb440cadd6.jpg', 1, 4),
(N'Sổ B5 Thiên Long kẻ ngang 7mm', N'Sổ tay', 'Thiên Long', N'Giấy B5, bìa cứng, giấy mịn đẹp, dễ ghi chú.', N'Việt Nam', 30000, 60, 'https://product.hstatic.net/1000230347/product/04_d1e08d80bcd143bd9b26d48aadd422ab.jpg', 1, 4),
(N'Sổ lò xo A6 Campus kẻ ngang', N'Sổ tay', 'Campus', N'Sổ nhỏ gọn tiện mang theo, giấy đẹp, bìa bền.', N'Trung Quốc', 18000, 65, 'https://product.hstatic.net/200000636461/product/f0a277216a224b16a84f5eee7f5bce3f_5bf5b5a7c4e44dd68862f69387dfc570.jpg', 1, 4);
INSERT INTO KhuyenMai (TenKhuyenMai, NgayBatDau, NgayKetThuc, PhanTramGiam, MoTaKhuyenMai, TrangThai) VALUES
(N'Khuyến mãi sinh viên', '2024-01-01', '2024-12-31', 10, N'Giảm giá 10% cho sinh viên có thẻ', 1),
(N'Khuyến mãi mua sỉ', '2024-01-01', '2024-12-31', 15, N'Giảm giá 15% cho đơn hàng trên 1 triệu', 1),
(N'Khuyến mãi cuối năm', '2024-12-01', '2024-12-31', 20, N'Giảm giá 20% dịp cuối năm', 1);

INSERT INTO DonHang (MaTaiKhoan, NgayDatHang, TongTienTruocGiam, TongTienSauKhiGiam, MaKhuyenMai, TrangThaiDonHang, MaDiaChi, HinhThucThanhToan, GhiChu, NgayCapNhat) VALUES
(2, '2024-12-10', 100000, 90000, 1, 4, 1, 1, N'Giao hàng trong giờ hành chính', GETDATE()),
(3, '2024-12-11', 62000, 62000, NULL, 2, 3, 2, N'Gọi trước khi giao', GETDATE()),
(4, '2024-12-12', 755000, 641750, 2, 3, 4, 3, N'Giao hàng nhanh', GETDATE());


INSERT INTO ChiTietDonHang (MaDonHang, MaSanPham, SoLuong, GiaBan, GhiChu) VALUES
(1, 1, 5, 8000, N'Bút bi xanh'),
(1, 3, 2, 30000, N'Sổ tay học tập'),
(2, 2, 3, 9000, N'Bút gel'),
(2, 5, 1, 25000, N'Keo dán');

SELECT * FROM SanPham;
SELECT * FROM ThongTinTaiKhoan;
SELECT * FROM DiaChiGiaoHang;
SELECT * FROM DanhMucSanPham
SELECT * FROM ThongTinTaiKhoan;

