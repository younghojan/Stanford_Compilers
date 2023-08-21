(*
 *  CS164 Fall 94
 *
 *  Programming Assignment 1
 *    Implementation of a simple stack machine.
 *
 *  Skeleton file
 *)

(* We are using chain stack here, a kind of stack implemented by linked list. *)

(* Define the nodes of the linked list. *)
class Node {

   val : String;
   next : Node;

   init(v : String, n : Node) : Node {
      {
         val <- v;
         next <- n;
         self;
      }
   };

   insert_tail(n : Node) : Node {
      {
         next <- n;
         self;
      }
   };

   get_val() : String {
      val
   };

   get_next() : Node {
      next
   };

};

(* Define the stack and the operations that can be performed on it. *)
class Stack {

   top : Node;
   capacity : Int;
   nil_node : Node <- new Node;

   init() : Stack {
      {  
         top <- nil_node;
         capacity <- 0;
         self;
      }
   };

   get_top() : Node {
      top
   };

   get_capacity() : Int {
      capacity
   };

   push(node : Node) : Stack {
      {
         node.insert_tail(top);
         top <- node;
         capacity <- capacity + 1;
         self;
      }
   };

   pop() : Stack {
      {
         top <- top.get_next();
         capacity <- capacity - 1;
         self;
      }
   };

   destroy() : Stack {
      {
         capacity <- capacity - capacity - 1;
         self;
      }
   };

};

class StackCommand inherits A2I {

   stack : Stack <- new Stack;

   init() : StackCommand {
      {  
         stack <- stack.init();
         self;
      }
   };

   get_capacity() : Int {
      stack.get_capacity()
   };

   push_command(cmd : String) : Stack {
      stack <- stack.push((new Node).init(cmd, stack.get_top()))
   };

   evaluate_command() : Stack {
      let op : String <- stack.get_top().get_val()
      in
         if (op = "+") then
            let left_operand_val : String <- stack.pop().get_top().get_val(),
                right_oprand_val : String <- stack.pop().get_top().get_val()
            in
               stack <- stack.pop().push(
                  (new Node).init(
                     i2a(a2i(left_operand_val) + a2i(right_oprand_val)),
                     stack.get_top()))
         else 
            if (op = "s") then
               let left_operand_node : Node <- stack.pop().get_top(),
                   right_oprand_node : Node <- stack.pop().get_top()
               in
                  stack <- stack.pop().push(left_operand_node).push(right_oprand_node)
            else
               stack
            fi
         fi
   };

   display() : Object {
      let i : Int <- 1,
          current_node : Node <- stack.get_top(),
          io : IO <- new IO
      in {
         while (i <= stack.get_capacity()) loop {
            io.out_string(current_node.get_val());
            io.out_string("\n");
            current_node <- current_node.get_next();
            i <- i + 1;
         }
         pool;
      }
   };

   step(cmd : String) : Object {
      if (cmd = "e") then
         evaluate_command()
      else
         if (cmd = "x") then
            stack.destroy()
         else
            if (cmd = "d") then
               display()
            else
               push_command(cmd)
            fi
         fi
      fi
   };

};

class Main inherits IO {

   main() : Object {
      let stack_command : StackCommand <- new StackCommand
      in {
         stack_command.init();
         while (0 <= stack_command.get_capacity()) loop {
            out_string(">");
            stack_command.step(in_string());
         }
         pool;
      }
   };

};
