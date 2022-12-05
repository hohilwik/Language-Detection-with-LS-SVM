import numpy as np


def numpy_json_encoder(obj):
    if type(obj).__module__ == np.__name__:
        if isinstance(obj, np.ndarray):
            return obj.tolist()
        else:
            return obj.item()
    raise TypeError(f"""Unable to  "jsonify" object of type :', {type(obj)}""")

