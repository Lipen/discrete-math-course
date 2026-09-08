//! A homomorphism Z_6 -> Z_3, its kernel and cosets, and the first
//! isomorphism theorem.

use algebra::homomorphism::{
    coset_product, image, is_homomorphism, is_normal, kernel, left_cosets,
};
use algebra::traits::Semigroup;
use algebra::Zn;

fn main() {
    // The reduction map phi: Z_6 -> Z_3, phi(x) = x mod 3.
    let z6: Vec<Zn<6>> = (0..6).map(Zn::new).collect();
    let phi = |z: &Zn<6>| Zn::<3>::new(z.0 % 3);

    println!("phi: Z_6 -> Z_3 sends x to x mod 3.");
    let four = Zn::<6>::new(4);
    let five = Zn::<6>::new(5);
    println!("phi(4 + 5) = phi(3) = {}", phi(&four.op(&five)).0);
    println!(
        "phi(4) + phi(5) = 1 + 2 = {}",
        Zn::<3>::new(1).op(&Zn::new(2)).0
    );
    println!("preserves the operation: {}", is_homomorphism(&z6, &phi));

    // The kernel: the elements sent to the identity 0.
    let k = kernel(&z6, &phi);
    println!(
        "\nkernel of phi = {:?}",
        k.iter().map(|z| z.0).collect::<Vec<_>>()
    );

    // The cosets of the kernel partition Z_6.
    let cosets = left_cosets(&z6, &k);
    println!("cosets of the kernel:");
    for c in &cosets {
        println!("  {:?}", c.iter().map(|z| z.0).collect::<Vec<_>>());
    }

    // The image has one element per coset.
    let im = image(&z6, &phi);
    println!("\nimage = {:?}", im.iter().map(|z| z.0).collect::<Vec<_>>());
    println!(
        "Z_6 / ker(phi) has {} cosets, one per image element:",
        cosets.len()
    );
    println!(
        "the first isomorphism theorem. ker(phi) is normal: {}",
        is_normal(&z6, &k)
    );

    // Coset multiplication: representatives 1 and 2 -> the coset of 1 + 2 = 3.
    let g = Zn::<6>::new(1);
    let h = Zn::<6>::new(2);
    let product = coset_product(&cosets, &g, &h);
    println!(
        "\n(1 + K)(2 + K) = coset of 3 = {:?}",
        product.iter().map(|z| z.0).collect::<Vec<_>>()
    );

    assert!(is_homomorphism(&z6, &phi));
    assert_eq!(k, vec![Zn::new(0), Zn::new(3)]);
    assert_eq!(cosets.len(), 3);
    assert_eq!(im.len(), 3);
    assert!(is_normal(&z6, &k));
}
