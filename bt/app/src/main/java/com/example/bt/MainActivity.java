package com.example.bt; // Bạn nhớ giữ nguyên dòng package này nhé

import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import androidx.appcompat.app.AppCompatActivity;
import androidx.cardview.widget.CardView;

public class MainActivity extends AppCompatActivity {

    private CardView cardKhoHang, cardHoaDon, cardDoanhThu;
    private Button btnLogout;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        // Ánh xạ các nút trên Trang chủ
        cardKhoHang = findViewById(R.id.cardKhoHang);
        cardHoaDon = findViewById(R.id.cardHoaDon);
        cardDoanhThu = findViewById(R.id.cardDoanhThu);
        btnLogout = findViewById(R.id.btnLogout);

        // 1. Mở trang Quản lý Kho Hàng
        cardKhoHang.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent intent = new Intent(MainActivity.this, InventoryActivity.class);
                startActivity(intent);
            }
        });

        // 2. Mở trang Tạo Hóa Đơn (Bán Hàng)
        cardHoaDon.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent intent = new Intent(MainActivity.this, BillingActivity.class);
                startActivity(intent);
            }
        });

        // 3. Mở trang Báo cáo Doanh Thu
        cardDoanhThu.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent intent = new Intent(MainActivity.this, RevenueActivity.class);
                startActivity(intent);
            }
        });

        // 4. Đăng Xuất (Quay về màn hình Login)
        btnLogout.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent intent = new Intent(MainActivity.this, LoginActivity.class);
                startActivity(intent);
                finish(); // Đóng trang chủ
            }
        });
    }
}