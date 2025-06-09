const std = @import("std");
const testing = std.testing;

const Error = error{EmptyList};

pub export fn add(a: i32, b: i32) i32 {
    return a + b;
}

test "basic add functionality" {
    try testing.expect(add(3, 7) == 10);
}

// Configuração do alocador

const allocator = std.heap.page_allocator;

// Nó da lista duplamente ligada

const Elemento = struct {
    data: i64 = 0,
    next: ?*Elemento,
    prev: ?*Elemento,
};

// A própria lista

pub const Lista = struct {
    head: ?*Elemento = null,
    tail: ?*Elemento = null,
    pub fn insert_back(self: *Lista, dat: i64) !void {
        const novo = try allocator.create(Elemento);
        novo.* = Elemento{ .data = dat, .next = null, .prev = null };

        if (self.head == null and self.tail == null) {
            self.head = novo;
            self.tail = novo;
        } else {
            novo.prev = self.tail;
            self.tail.?.next = novo;
            self.tail = novo;
        }
    }

    pub fn remove_back(self: *Lista) !void {
        if (self.tail == null) {
            return Error.EmptyList;
        }
        const to_remove = self.tail.?;
        if (self.head == self.tail) {
            self.head = null;
            self.tail = null;
            defer allocator.destroy(to_remove);
        } else {
            self.tail = to_remove.prev;
            self.tail.?.next = null;
            defer allocator.destroy(to_remove);
        }
    }

    pub fn print(self: *Lista) !void {
        var atual: ?*Elemento = self.head;

        while (atual) |node| {
            std.debug.print("{} ", .{node.data});
            atual = node.next;
        }
        std.debug.print("\n", .{});
    }

    pub fn cont(self: *Lista) u64 {
        var contador: u64 = 0;

        var atual: ?*Elemento = self.head;
        while (atual) |node| {
            contador += 1;
            atual = node.next;
        }
        return contador;
    }

    pub fn clear(self: *Lista) !void {
        var atual: ?*Elemento = self.head;

        while (atual) |node| {
            const proximo: ?*Elemento = node.next;
            allocator.destroy(node);
            atual = proximo;
        }
        self.head = null;
        self.tail = null;
    }
};

// Testes para a lista

test "Clear com valor" {
    var list = Lista{};
    try list.insert_back(64);
    try list.clear();
    try testing.expect(list.cont() == 0);
}
test "Clear sem valor" {
    var list = Lista{};
    try list.clear();
    try testing.expect(list.cont() == 0);
}

test "Contador sem elementos" {
    var list = Lista{};
    try testing.expect(list.cont() == 0);
}
test "Contador com elementos" {
    var list = Lista{};
    try list.insert_back(123);
    try list.insert_back(123);
    try list.insert_back(123);
    try list.insert_back(123);
    try list.insert_back(123);
    try list.insert_back(123);

    try testing.expect(list.cont() == 6);
}
test "insert into empty list" {
    var list = Lista{};
    try list.insert_back(123);
    try testing.expect(list.head.?.data == 123);
    try testing.expect(list.tail.?.data == 123);
}

test "insert into non-empty list" {
    var list = Lista{};
    try list.insert_back(10);
    try list.insert_back(20);
    try testing.expect(list.head.?.data == 10);
    try testing.expect(list.tail.?.data == 20);
    try testing.expect(list.head.?.next.?.data == 20);
    try testing.expect(list.tail.?.prev.?.data == 10);
}

// Teste de inserção e remoção

test "insert and remove back operations" {
    var list = Lista{};
    try list.insert_back(10);
    try list.insert_back(20);
    try list.insert_back(30);

    try list.remove_back(); // remove 30
    try testing.expect(list.tail.?.data == 20);

    try list.remove_back(); // remove 20
    try testing.expect(list.tail.?.data == 10);

    try list.remove_back(); // remove 10, lista fica vazia
    try testing.expect(list.tail == null and list.head == null);

    // Remover em lista vazia retorna erro
    try testing.expectError(Error.EmptyList, list.remove_back());
}
