use std::fs;
use std::collections::HashMap;

fn parse_graph(input: &str) -> HashMap<String, Vec<String>> {
    input.lines().map(|line| {
        let mut parts = line.split(" -> ");
        let parent = parts.next().unwrap();
        let child = parts.next().unwrap();
        (parent.to_string(), child.to_string())
    }).fold(HashMap::new(), |mut map, (parent, child)| {
        map.entry(parent).or_insert(vec![]).push(child);
        map
    })
}

fn khan_topological_sort(graph: &HashMap<String, Vec<String>>) -> Vec<String> {
    let mut in_edges = graph.iter().fold(HashMap::new(), |mut map, (_, children)| {
        children.iter().for_each(|child| {
            map.entry(child).or_insert(0);
            *map.get_mut(child).unwrap() += 1;
        });
        map
    });

    let mut queue = graph.iter().filter_map(|(node, _)| {
        if in_edges.get(node).unwrap_or(&0) == &0 {
            Some(node.clone())
        } else {
            None
        }
    }).collect::<Vec<String>>();

    let mut result = vec![];
    while !queue.is_empty() {
        let node = queue.pop().unwrap();
        result.push(node.clone());
        if let Some(children) = graph.get(&node) {
            children.iter().for_each(|child| {
                let count = in_edges.get_mut(child).unwrap();
                *count -= 1;
                if *count == 0 {
                    queue.push(child.clone());
                }
            });
        }
    }

    result
}

fn format_result(result: &Vec<String>) -> String {
    result.join(" -> ")
}

fn main() {
    let input_file = "input.txt";

    let contents = fs::read_to_string(input_file)
        .expect("Something went wrong reading the file");

    let graph = parse_graph(&contents);
    let result = khan_topological_sort(&graph);
    let formatted_result = format_result(&result);

    println!("{}", formatted_result);
}
