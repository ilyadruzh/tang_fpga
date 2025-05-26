// Модуль мигания светодиода
module blink (
    // Входной тактовый сигнал
    input wire clock,
    // Выход для управления уровнем IO
    output reg IO_voltage
);
/********** Счётчик **********/
//parameter Clock_frequency = 27_000_000; // Частота кварцевого резонатора 27 МГц
parameter count_value       = 13_499_999; // Количество тактов для 0.5 секунды

// Регистр счётчика
reg [23:0]  count_value_reg ; // текущее значение счётчика
// Флаг, указывающий на необходимость смены уровня на выводе
reg         count_value_flag; 

// Процесс подсчёта времени
always @(posedge clock) begin
    // Если время ещё не истекло
    if ( count_value_reg <= count_value ) begin
        count_value_reg  <= count_value_reg + 1'b1; // продолжаем счёт
        count_value_flag <= 1'b0 ;                  // флаг не выставляем
    end
    else begin
        // Время истекло: сбрасываем счётчик
        count_value_reg  <= 23'b0;
        count_value_flag <= 1'b1 ;                  // устанавливаем флаг
    end
end

/********** Переключение уровня IO **********/
reg IO_voltage_reg = 1'b0; // начальное состояние

// Процесс смены уровня
always @(posedge clock) begin
    if ( count_value_flag )  // при выставленном флаге
        IO_voltage_reg <= ~IO_voltage_reg; // инвертируем уровень
    else                    // иначе
        IO_voltage_reg <= IO_voltage_reg; // оставляем без изменений
end

/***** Вывод значения на контакт *****/
assign IO_voltage = IO_voltage_reg;

endmodule
