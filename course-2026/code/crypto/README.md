# crypto

Теория чисел и криптография.

## Компоненты

- Модулярная арифметика: алгоритм Евклида, обратные элементы, быстрое возведение в степень.
- RSA: генерация ключей, шифрование и дешифрование.
- `attacks`: атаки на криптосистемы.

## Атаки

- `brute_force_caesar` --- полный перебор сдвигов шифра Цезаря.
- `frequency_analysis` --- частотный анализ шифра простой замены.
- `common_modulus` --- атака с общим модулем на RSA.
- `malleability` --- маллобильность RSA.
- `pohlig_hellman` --- атака Полига--Хеллмана на дискретный логарифм.

## Примеры

```bash
cargo run -p crypto --example common_modulus
cargo run -p crypto --example malleability
cargo run -p crypto --example pohlig_hellman
```

## Тесты

```bash
cargo test -p crypto
```
