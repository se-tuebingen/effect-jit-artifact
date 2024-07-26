#include <gtest/gtest.h>
#include "../list.h"

TEST(ListTest, Empty) {
  ASSERT_EQ(list::Nil<int>(), nullptr);
}

TEST(ListTest, Head) {
  auto l = list::Cons(42, list::Nil<int>());
  ASSERT_EQ(42, l->head);
}

TEST(ListTest, Tail) {
  auto l = list::Cons(42, list::Nil<int>());
  ASSERT_EQ(nullptr, l->tail);
}

TEST(ListTest, HeadAndTail1) {
  auto l = list::Cons(44, list::Nil<int>());
  ASSERT_EQ(44, l->head);

  auto l2 = l->tail;
  ASSERT_EQ(l2, nullptr);
}

TEST(ListTest, HeadAndTail2) {
  auto l = list::Cons(44, list::Cons(42, list::Nil<int>()));
  ASSERT_EQ(44, l->head);

  auto l2 = l->tail;
  ASSERT_EQ(42, l2->head);
}

TEST(ListTest, Nth1) {
  auto l = list::Cons(44, list::Cons(42, list::Nil<int>()));
  ASSERT_EQ(list::Nth(0, l), l->head);

  auto l2 = l->tail;
  ASSERT_EQ(list::Nth(1, l), l2->head);
}

TEST(ListTest, Nth2) {
  auto l = list::Cons(26, list::Cons(59, list::Cons(44, list::Cons(42, list::Nil<int>()))));
  ASSERT_EQ(list::Nth(0, l), 26);
  ASSERT_EQ(list::Nth(1, l), 59);
  ASSERT_EQ(list::Nth(2, l), 44);
  ASSERT_EQ(list::Nth(3, l), 42);
}

TEST(ListTest, Shared) {
  auto l = list::Cons(42, list::Nil<int>());
  auto l2 = list::Cons(26, list::Cons(59, list::Cons(44, l)));
  auto l3 = list::Cons(55, list::Cons(44, l));

  ASSERT_EQ(list::Nth(0, l2), 26);
  ASSERT_EQ(list::Nth(1, l2), 59);
  ASSERT_EQ(list::Nth(2, l2), 44);
  ASSERT_EQ(list::Nth(3, l2), 42);

  ASSERT_EQ(list::Nth(0, l3), 55);
  ASSERT_EQ(list::Nth(1, l3), 44);
  ASSERT_EQ(list::Nth(2, l3), 42);
}
