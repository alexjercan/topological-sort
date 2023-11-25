from collections import defaultdict


def parse_graph(content):
    lines = content.splitlines()

    graph = defaultdict(list)
    for line in lines:
        parent, child = (tuple(line.split(" -> ")))
        graph[parent].append(child)

    return graph


def khan_topological_sort(graph):
    in_edges = defaultdict(int)

    for node in graph:
        for child in graph[node]:
            in_edges[child] += 1

    queue = [node for node in graph if in_edges[node] == 0]

    result = []
    while queue:
        node = queue.pop(0)
        result.append(node)

        for child in graph[node]:
            in_edges[child] -= 1
            if in_edges[child] == 0:
                queue.append(child)

    return result


def format_result(result):
    return " -> ".join(result)


def main():
    input_file = "input.txt"

    with open(input_file, "r") as f:
        content = f.read()

    graph = parse_graph(content)

    result = khan_topological_sort(graph)

    print(format_result(result))


if __name__ == "__main__":
    main()
