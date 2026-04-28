package com.example.bt;

import android.database.Cursor;
import android.os.Bundle;
import android.view.View;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ListView;
import android.widget.Spinner;
import android.widget.TextView;
import android.widget.Toast;
import androidx.appcompat.app.AppCompatActivity;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.Locale;

public class BillingActivity extends AppCompatActivity {

    private Button btnBack, btnThemVaoDon, btnThanhToan;
    private Spinner spinnerThuoc;
    private EditText edtSoLuongBan;
    private ListView lvChiTietDon;
    private TextView tvTongTien;

    private DatabaseHelper dbHelper;

    // Dữ liệu cho ô chọn thuốc
    private ArrayList<String> listTenThuoc;
    private ArrayList<Integer> listIdThuoc;
    private ArrayList<Integer> listGiaThuoc;
    private ArrayList<Integer> listTonKho;
    private ArrayAdapter<String> spinnerAdapter;

    // Dữ liệu cho Giỏ hàng
    private ArrayList<String> listGioHang;
    private ArrayAdapter<String> gioHangAdapter;

    // Bộ nhớ tạm để tính tiền và trừ kho
    private ArrayList<Integer> listIdMua;
    private ArrayList<Integer> listSoLuongMua;
    private int tongTienHoaDon = 0;
    private StringBuilder chiTietHoaDon;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_billing);

        btnBack = findViewById(R.id.btnBackToHomeFromBilling);
        btnThemVaoDon = findViewById(R.id.btnThemVaoDon);
        btnThanhToan = findViewById(R.id.btnThanhToan);
        spinnerThuoc = findViewById(R.id.spinnerThuoc);
        edtSoLuongBan = findViewById(R.id.edtSoLuongBan);
        lvChiTietDon = findViewById(R.id.lvChiTietDon);
        tvTongTien = findViewById(R.id.tvTongTien);

        dbHelper = new DatabaseHelper(this);

        listTenThuoc = new ArrayList<>();
        listIdThuoc = new ArrayList<>();
        listGiaThuoc = new ArrayList<>();
        listTonKho = new ArrayList<>();
        listGioHang = new ArrayList<>();
        listIdMua = new ArrayList<>();
        listSoLuongMua = new ArrayList<>();
        chiTietHoaDon = new StringBuilder();

        spinnerAdapter = new ArrayAdapter<>(this, android.R.layout.simple_spinner_dropdown_item, listTenThuoc);
        spinnerThuoc.setAdapter(spinnerAdapter);

        gioHangAdapter = new ArrayAdapter<>(this, android.R.layout.simple_list_item_1, listGioHang);
        lvChiTietDon.setAdapter(gioHangAdapter);

        loadDanhSachThuoc();

        btnBack.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                finish();
            }
        });

        // XỬ LÝ THÊM VÀO GIỎ HÀNG
        btnThemVaoDon.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                int viTriChon = spinnerThuoc.getSelectedItemPosition();
                if (viTriChon < 0) {
                    Toast.makeText(BillingActivity.this, "Kho không có thuốc!", Toast.LENGTH_SHORT).show();
                    return;
                }

                String slStr = edtSoLuongBan.getText().toString().trim();
                if (slStr.isEmpty()) {
                    Toast.makeText(BillingActivity.this, "Nhập số lượng bán!", Toast.LENGTH_SHORT).show();
                    return;
                }

                int slMua = Integer.parseInt(slStr);
                int tonKho = listTonKho.get(viTriChon);

                if (slMua <= 0) {
                    Toast.makeText(BillingActivity.this, "Số lượng phải lớn hơn 0", Toast.LENGTH_SHORT).show();
                    return;
                }
                if (slMua > tonKho) {
                    Toast.makeText(BillingActivity.this, "Kho chỉ còn " + tonKho + " hộp!", Toast.LENGTH_SHORT).show();
                    return;
                }

                // Lấy thông tin thuốc được chọn
                int idThuoc = listIdThuoc.get(viTriChon);
                String tenThuoc = listTenThuoc.get(viTriChon);
                int giaThuoc = listGiaThuoc.get(viTriChon);
                int thanhTien = giaThuoc * slMua;

                // Thêm vào bộ nhớ tạm
                listIdMua.add(idThuoc);
                listSoLuongMua.add(slMua);
                tongTienHoaDon += thanhTien;

                // Hiển thị lên màn hình
                String dongChiTiet = tenThuoc + " x " + slMua + " = " + thanhTien + " VNĐ";
                listGioHang.add(dongChiTiet);
                gioHangAdapter.notifyDataSetChanged();

                chiTietHoaDon.append(dongChiTiet).append("\n");
                tvTongTien.setText(tongTienHoaDon + " VNĐ");

                edtSoLuongBan.setText(""); // Xóa trắng ô nhập số lượng
            }
        });

        // XỬ LÝ THANH TOÁN
        btnThanhToan.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (listGioHang.isEmpty()) {
                    Toast.makeText(BillingActivity.this, "Giỏ hàng đang trống!", Toast.LENGTH_SHORT).show();
                    return;
                }

                // Lấy giờ hiện tại làm mã/thời gian
                String ngayTao = new SimpleDateFormat("dd/MM/yyyy HH:mm:ss", Locale.getDefault()).format(new Date());

                // 1. Lưu hóa đơn vào Database
                boolean success = dbHelper.addHoaDon(ngayTao, chiTietHoaDon.toString(), tongTienHoaDon);

                if (success) {
                    // 2. Trừ số lượng tồn trong kho
                    for (int i = 0; i < listIdMua.size(); i++) {
                        dbHelper.updateTonKho(listIdMua.get(i), listSoLuongMua.get(i));
                    }
                    Toast.makeText(BillingActivity.this, "Thanh toán thành công!", Toast.LENGTH_LONG).show();
                    finish(); // Trở về trang chủ
                } else {
                    Toast.makeText(BillingActivity.this, "Lỗi khi lưu hóa đơn!", Toast.LENGTH_SHORT).show();
                }
            }
        });
    }

    private void loadDanhSachThuoc() {
        Cursor cursor = dbHelper.getAllThuoc();
        listTenThuoc.clear(); listIdThuoc.clear(); listGiaThuoc.clear(); listTonKho.clear();

        while (cursor.moveToNext()) {
            listIdThuoc.add(cursor.getInt(0));
            listTenThuoc.add(cursor.getString(1));
            listGiaThuoc.add(cursor.getInt(2));
            listTonKho.add(cursor.getInt(3));
        }
        cursor.close();
        spinnerAdapter.notifyDataSetChanged();
    }
}