const std = @import("std");
const testing = std.testing;
const allocator = std.heap.page_allocator;

pub const Error = error{EmptyQueue};

const Elem = struct { data: i64, next: ?*Elem, prev: ?*Elem };

pub const Fila = struct {
    head: ?*Elem = null,
    tail: ?*Elem = null,

    pub fn enqueue(self: *Fila, dat: i64) !void {
        const novo = try allocator.create(Elem);
        novo.* =
            Elem{ .data = dat, .next = null, .prev = null };
        if (self.head == null and self.tail == null) {
            self.head = novo;
            self.tail = novo;
        } else {
            novo.prev = self.tail;
            self.tail.?.next = novo;
            self.tail = novo;
        }
    }

    pub fn dequeue(self: *Fila) !i64 {
        if (self.head == null) {
            return Error.EmptyQueue;
        } else {
            const valor: i64 = self.head.?.data;
            const antigo: *Elem = self.head.?;
            defer (allocator.destroy(antigo));
            self.head = antigo.next;

            if (self.head == null) {
                self.tail = null;
            } else {
                self.head.?.prev = null;
            }

            return valor;
        }
    }

    pub fn isEmpty(self: *Fila) bool {
        return self.head == null;
    }
    pub fn peek(self: *Fila) !i64 {
        if (self.head == null) {
            return Error.EmptyQueue;
        }
        return self.head.?.data;
    }
};
