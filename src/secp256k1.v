`timescale 1ns/1ps // единицы времени и точность моделирования

// Генерация стойких ключей secp256k1
module secp256k1_keygen(
    input  wire        clk,              // тактовый сигнал
    input  wire        rst,              // асинхронный сброс
    input  wire        start,            // запрос на начало генерации
    input  wire        entropy_valid,    // флаг наличия данных энтропии
    input  wire [31:0] entropy_data,     // 32‑битные случайные данные
    output reg         done,             // флаг окончания работы
    output reg  [255:0] priv_key,        // закрытый ключ
    output reg  [255:0] pub_key_x,       // X‑координата открытого ключа
    output reg  [255:0] pub_key_y        // Y‑координата открытого ключа
); // конец описания портов

    // Параметры поля secp256k1
    localparam P = 256'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F; // простое число поля
    localparam N = 256'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141; // порядок базовой точки
    localparam GX = 256'h79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798; // X‑координата базовой точки
    localparam GY = 256'h483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8; // Y‑координата базовой точки

    // Состояния автомата
    localparam S_IDLE     = 2'd0; // ожидание команды
    localparam S_COLLECT  = 2'd1; // сбор энтропии
    localparam S_COMPUTE  = 2'd2; // вычисление открытого ключа
    localparam S_DONE     = 2'd3; // завершение

    reg [1:0] state;        // текущие состояние
    reg [2:0] word_count;   // количество полученных 32‑битных слов

    // Вспомогательные регистры для вычислений
    reg [255:0] k;          // рабочая переменная для закрытого ключа
    reg [255:0] x1, y1;     // первая точка
    reg [255:0] x2, y2;     // вторая точка

    // Функция модульного сложения
    function [255:0] mod_add;
        input [255:0] a; // первое слагаемое
        input [255:0] b; // второе слагаемое
        reg [256:0] s;   // промежуточная сумма
        begin
            s = a + b;                      // складываем
            if (s >= P)                     // если сумма вышла за пределы поля
                mod_add = s - P;            // вычитаем модуль
            else
                mod_add = s[255:0];         // иначе возвращаем результат
        end
    endfunction

    // Функция модульного вычитания
    function [255:0] mod_sub;
        input [255:0] a; // уменьшаемое
        input [255:0] b; // вычитаемое
        begin
            if (a >= b)                     // если уменьшаемое больше
                mod_sub = a - b;            // просто вычитаем
            else
                mod_sub = P - (b - a);      // иначе берём значение по модулю
        end
    endfunction

    // Функция модульного умножения (наивная)
    function [255:0] mod_mul;
        input [255:0] a; // первый множитель
        input [255:0] b; // второй множитель
        integer i;       // счётчик цикла
        reg [511:0] p;   // промежуточное произведение
        begin
            p = 0;
            for (i = 0; i < 256; i = i + 1) begin // перебираем биты
                if (b[i])                         // если бит установлен
                    p = p + (a << i);             // добавляем сдвинутый множитель
            end
            for (i = 511; i >= 256; i = i - 1) begin // редукция
                if (p[i])
                    p = p - (P << (i-256));
            end
            if (p[255:0] >= P)
                mod_mul = p[255:0] - P;          // окончательная коррекция
            else
                mod_mul = p[255:0];
        end
    endfunction

    // Функция возведения в степень p-2 (обратный элемент)
    function [255:0] mod_inv;
        input [255:0] a; // аргумент
        reg [255:0] r;  // промежуточный результат
        integer i;      // счётчик
        begin
            r = a;
            for (i = 0; i < 254; i = i + 1)
                r = mod_mul(mod_mul(r, r), a); // квадрат и умножение
            mod_inv = r;                       // возвращаем обратное значение
        end
    endfunction

    // Удвоение точки на кривой
    task point_double;
        input  [255:0] ax; // X входной точки
        input  [255:0] ay; // Y входной точки
        output [255:0] rx; // X результата
        output [255:0] ry; // Y результата
        reg [255:0] l;     // наклон касательной
        begin
            l  = mod_mul(mod_mul(256'd3, mod_mul(ax, ax)), mod_inv(mod_mul(256'd2, ay))); // расчёт наклона
            rx = mod_sub(mod_mul(l, l), mod_mul(256'd2, ax));                              // координата X
            ry = mod_sub(mod_mul(l, mod_sub(ax, rx)), ay);                                // координата Y
        end
    endtask

    // Сложение двух точек
    task point_add;
        input  [255:0] ax; // X первой точки
        input  [255:0] ay; // Y первой точки
        input  [255:0] bx; // X второй точки
        input  [255:0] by; // Y второй точки
        output [255:0] rx; // X результата
        output [255:0] ry; // Y результата
        reg [255:0] l;     // наклон секущей
        begin
            if (ax == bx && ay == by) begin
                point_double(ax, ay, rx, ry);   // если точки совпадают, удваиваем
            end else begin
                l  = mod_mul(mod_sub(by, ay), mod_inv(mod_sub(bx, ax))); // наклон прямой
                rx = mod_sub(mod_sub(mod_mul(l, l), ax), bx);             // координата X
                ry = mod_sub(mod_mul(l, mod_sub(ax, rx)), ay);            // координата Y
            end
        end
    endtask

    // Умножение точки на скаляр (алгоритм лестницы Монтгомери)
    task scalar_mult;
        input  [255:0] d;  // скаляр
        output [255:0] rx; // X результата
        output [255:0] ry; // Y результата
        reg [255:0] x0, y0; // точка R0
        reg [255:0] x1, y1; // точка R1
        integer i;          // счётчик
        begin
            x0 = 0; y0 = 0;         // бесконечность
            x1 = GX; y1 = GY;       // базовая точка
            for (i = 255; i >= 0; i = i - 1) begin
                if (d[i] == 1'b0) begin
                    point_add(x1, y1, x0, y0, x1, y1); // R1 = R1 + R0
                    point_double(x0, y0, x0, y0);      // R0 = 2*R0
                end else begin
                    point_add(x0, y0, x1, y1, x0, y0); // R0 = R0 + R1
                    point_double(x1, y1, x1, y1);      // R1 = 2*R1
                end
            end
            rx = x0;
            ry = y0;
        end
    endtask

    // Автомат управления
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state      <= S_IDLE;   // сброс в начальное состояние
            done       <= 1'b0;     // сбрасываем флаг готовности
            priv_key   <= 256'b0;   // обнуляем ключ
            pub_key_x  <= 256'b0;   // обнуляем X
            pub_key_y  <= 256'b0;   // обнуляем Y
            word_count <= 3'b0;     // счётчик слов энтропии
        end else begin
            case (state)
                S_IDLE: begin
                    done <= 1'b0;                 // сброс флага
                    if (start) begin              // при команде старт
                        word_count <= 3'd0;       // обнуляем счётчик
                        state      <= S_COLLECT;  // переходим к сбору энтропии
                    end
                end

                S_COLLECT: begin
                    if (entropy_valid) begin
                        priv_key <= {priv_key[223:0], entropy_data}; // сдвигаем и добавляем данные
                        word_count <= word_count + 1'b1;             // увеличиваем счётчик
                        if (word_count == 3'd7) begin                // набрали восемь слов
                            if (priv_key >= N)
                                priv_key <= priv_key - N;            // приведение к диапазону
                            state <= S_COMPUTE;                      // переходим к вычислению
                        end
                    end
                end

                S_COMPUTE: begin
                    scalar_mult(priv_key, pub_key_x, pub_key_y);     // вычисляем открытый ключ
                    state <= S_DONE;                                 // завершаем
                end

                S_DONE: begin
                    done  <= 1'b1;                                   // ставим флаг готовности
                    state <= S_IDLE;                                 // возвращаемся в ожидание
                end
            endcase
        end
    end

endmodule