const std = @import("std");

// Importa o módulo com a definição da lista (root.zig deve estar no mesmo diretório)
const lib = @import("root.zig");
const lib2 = @import("fila.zig");
pub fn main() !void {
    // Inicializa a lista vazia
    var list = lib.Lista{ .head = null, .tail = null };

    // Insere os valores 10, 22, 35, 45, 78 na lista
    try list.insert_back(10);
    try list.insert_back(22);
    try list.insert_back(35);
    try list.insert_back(45);
    try list.insert_back(78);

    // Itera sobre a lista do head até o tail para exibir os valores
    try list.print();

    //try std.debug.print("Quantidade de elementos {} ", .{list.cont()});
    std.debug.print("Quantidade de elementos: {}\n", .{list.cont()});

    var fila = lib2.Fila{}; // constrói uma fila vazia

    // Tenta enfileirar alguns valores
    try fila.enqueue(10);
    try fila.enqueue(20);
    try fila.enqueue(30);

    // "Olha" o topo sem remover (deve imprimir 10)
    const topo = try fila.peek();
    std.debug.print("Peek: {}\n", .{topo}); // Peek: 10

    // Faz 3 dequeues e imprime cada valor
    while (!fila.isEmpty()) {
        const x = try fila.dequeue();
        std.debug.print("Dequeued: {}\n", .{x});
    }
    // Saída esperada:
    // Dequeued: 10
    // Dequeued: 20
    // Dequeued: 30

    // Agora a fila está vazia. Próximo dequeue deve retornar erro.
    const result = fila.dequeue();
    if (result) |ok_val| {
        // não deve ocorrer neste caso
        std.debug.print("Dequeued (unexpected): {}\n", .{ok_val});
    } else |err| {
        // Aqui deve ser Error.EmptyQueue
        std.debug.print("Erro ao dequeue: {}\n", .{err});
    }
}
