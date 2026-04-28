package com.example.bt; // Nhớ kiểm tra dòng này

import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.TextView;
import android.widget.Toast;
import androidx.appcompat.app.AppCompatActivity;

public class RegisterActivity extends AppCompatActivity {

    private EditText edtRegUsername, edtRegPassword, edtRegConfirmPassword;
    private Button btnRegisterSubmit;
    private TextView tvBackToLogin;
    private DatabaseHelper dbHelper;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_register);

        // Ánh xạ
        edtRegUsername = findViewById(R.id.edtRegUsername);
        edtRegPassword = findViewById(R.id.edtRegPassword);
        edtRegConfirmPassword = findViewById(R.id.edtRegConfirmPassword);
        btnRegisterSubmit = findViewById(R.id.btnRegisterSubmit);
        tvBackToLogin = findViewById(R.id.tvBackToLogin);
        dbHelper = new DatabaseHelper(this);

        // Bấm nút ĐĂNG KÝ
        btnRegisterSubmit.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                String user = edtRegUsername.getText().toString().trim();
                String pass = edtRegPassword.getText().toString().trim();
                String confirmPass = edtRegConfirmPassword.getText().toString().trim();

                // Kiểm tra nhập thiếu
                if(user.isEmpty() || pass.isEmpty() || confirmPass.isEmpty()) {
                    Toast.makeText(RegisterActivity.this, "Vui lòng nhập đủ thông tin!", Toast.LENGTH_SHORT).show();
                    return;
                }

                // Kiểm tra mật khẩu khớp nhau
                if(!pass.equals(confirmPass)) {
                    Toast.makeText(RegisterActivity.this, "Mật khẩu nhập lại không khớp!", Toast.LENGTH_SHORT).show();
                    return;
                }

                // Lưu vào Database
                boolean isSuccess = dbHelper.addUser(user, pass);
                if(isSuccess) {
                    Toast.makeText(RegisterActivity.this, "Đăng ký thành công!", Toast.LENGTH_SHORT).show();
                    finish(); // Đóng trang đăng ký, tự động quay về trang Đăng nhập
                } else {
                    Toast.makeText(RegisterActivity.this, "Đăng ký thất bại (Tên tài khoản có thể đã tồn tại)!", Toast.LENGTH_SHORT).show();
                }
            }
        });

        // Bấm nút Quay lại Đăng nhập
        tvBackToLogin.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                finish(); // Tắt trang Đăng ký
            }
        });
    }
}