ip = get_ipython()

ip.run_line_magic("load_ext", "autoreload")
ip.run_line_magic("autoreload", "3")


try:
    from rich import print as p
    from rich.console import Console
    from rich.traceback import install as install_rich_traceback

    console = Console()
    install_rich_traceback()
except ModuleNotFoundError as e:
    print(e)

try:
    import kitcat
    import matplotlib

    matplotlib.use("kitcat")

    import matplotlib.pyplot as plt
except ModuleNotFoundError as e:
    print(e)
