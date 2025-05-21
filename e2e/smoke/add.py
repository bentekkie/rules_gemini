from argparse import ArgumentParser
import sys


if __name__ == '__main__':
    parser = ArgumentParser()
    parser.add_argument('--first', type=int, required=True)
    parser.add_argument('--second', type=int, required=True)
    args = parser.parse_args()
    print(args.first + args.second)
