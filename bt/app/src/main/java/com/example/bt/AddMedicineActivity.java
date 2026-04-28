package com.example.bt;

import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.Toast;
import androidx.appcompat.app.AppCompatActivity;

public class AddMedicineActivity extends AppCompatActivity {

    private EditText edtTenThuoc, edtGiaBan, edtSoLuong;
    private Button btnLuuThuoc, btnHuyAdd;
    private DatabaseHelper dbHelper;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_add_medicine);

        edtTenThuoc = findViewById(R.id.edtTenThuoc);
        edtGiaBan = findViewById(R.id.edtGiaBan);
        edtSoLuong = findViewById(R.id.edtSoLuong);
        btnLuuThuoc = findViewById(R.id.btnLuuThuoc);
        btnHuyAdd = findViewById(R.id.btnHuyAdd);

        dbHelper = new DatabaseHelper(this);

        // Lưu thuốc
        btnLuuThuoc.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                String ten = edtTenThuoc.getText().toString().trim();
                String giaStr = edtGiaBan.getText().toString().trim();
                String slStr = edtSoLuong.getText().toString().trim();

                if(ten.isEmpty() || giaStr.isEmpty() || slStr.isEmpty()) {
                    Toast.makeText(AddMedicineActivity.this, "Vui lòng nhập đủ thông tin!", Toast.LENGTH_SHORT).show();
                    return;
                }

                int gia = Integer.parseInt(giaStr);
                int sl = Integer.parseInt(slStr);

                boolean success = dbHelper.addThuoc(ten, gia, sl);
                if(success) {
                    Toast.makeText(AddMedicineActivity.this, "Đã thêm thuốc thành công!", Toast.LENGTH_SHORT).show();
                    finish(); // Trở về kho
                } else {
                    Toast.makeText(AddMedicineActivity.this, "Lỗi khi lưu thuốc!", Toast.LENGTH_SHORT).show();
                }
            }
        });

        // Hủy
        btnHuyAdd.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                finish(); // Đóng trang không làm gì cả
            }
        });
    }
}