import sys, importlib.util
spec = importlib.util.find_spec('torch')
print('torch spec', spec)
if spec:
    import torch
    print('torch version', torch.__version__)
else:
    print('torch not installed')

