#ifndef LIST_H_
#define LIST_H_

#include <memory>

namespace list {

template<class T>
struct Node {
  public:
    Node(const T& elem, const std::shared_ptr<Node<T>>& tail) :
      head(elem),
      tail(tail) {}

    Node(const T& elem, std::shared_ptr<Node<T>>&& tail) :
      head(elem),
      tail(std::move(tail)) {}

    Node(T&& elem, std::shared_ptr<Node<T>>&& tail) :
      head(std::move(elem)),
      tail(std::move(tail)) {}

    const T head;
    std::shared_ptr<Node<T>> tail;

    ~Node() {
      std::shared_ptr<Node<T>> next;
      next = tail;
      tail = nullptr;

      while (next.use_count() == 1) {
        next = next->tail;
      }
    }
};

template<class T>
using List = std::shared_ptr<Node<T>>;

template<class T>
const List<T> Nil() {
  return nullptr;
}

template<class T>
List<T> Cons(const T& x, const List<T>& list) {
  return std::make_shared<Node<T>>(x, list);
}

template<class T>
List<T> Cons(const T& x, List<T>&& list) {
  return std::make_shared<Node<T>>(x, list);
}

template<class T>
List<T> Cons(T&& x, List<T>&& list) {
  return std::make_shared<Node<T>>(x, list);
}

template<class T>
const T& Nth(size_t i, const List<T>& list) {
  Node<T>* ptr = list.get();
  for (size_t j = 0; j < i; j++)
    ptr = ptr->tail.get();

  return ptr->head;
}

} // namespace list

#endif  // LIST_H_
