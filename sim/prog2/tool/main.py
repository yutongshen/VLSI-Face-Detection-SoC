from subprocess import Popen, PIPE, STDOUT
import struct

class fakeenv:
  cnt = 0
  def __init__(self):
    pass

  def _state(self):
    return float(self.cnt % 91) / 7, float(self.cnt % 89) / 7

  def reset(self):
    self.cnt = 0
    return self._state()

  def step(self, a):
    if a == 0:
      self.cnt = self.cnt * 2
    elif a == 2:
      self.cnt = self.cnt // 2
    self.cnt += 1

    done = False
    if self.cnt > 1000:
        self.cnt = 0
        done = True
   
    return self._state(), self.cnt // 100, done, 0

  def render(self):
    pass


proc = Popen("./dqn",
             stdin=PIPE,
             stdout=PIPE,
             stderr=PIPE)
def int2bytes(integer):
  if integer < 0: integer += 1 << 32
  return integer.to_bytes(4, byteorder='little')

def state2bytes(state):
  pos, vel = state
  #pos = int(pos * 256)
  #vel = int(vel * 256)
  #return int2bytes(pos) + int2bytes(vel)
  return struct.pack('d', pos) + struct.pack('d', vel)

def reset(env, verbose):
  if verbose: print('(reset)')
  s = env.reset()
  msg = state2bytes(s)
  #proc.stdin.write(bytes(msg))
  proc.stdin.write(msg)
  proc.stdin.flush()
  
def render(env, verbose):
  # if verbose: print('(render)')
  env.render()

def step(env, verbose):
  # if verbose: print('(step)')
  # receive action
  a = int.from_bytes(proc.stdout.read(1), byteorder='little')
  s_, r, done, _ = env.step(a)
  msg = state2bytes(s_) + int2bytes(int(r)) + int2bytes(int(done))
  #proc.stdin.write(bytes(msg))
  proc.stdin.write(msg)
  proc.stdin.flush()

def str_print(verbose):
  if verbose:
    print('(print)')
  msg = proc.stdout.readline().decode()
  print(msg, end='')

def close(env, verbose):
  if verbose: print('(close)')


# 0: env.close()
# 1: env.reset()
# 2: env.render()
# 3: env.step()
def listen_cmd(env, verbose=True):
  while True:
    cmd = int.from_bytes(proc.stdout.read(1), byteorder='little')
    excute = {
      0: lambda: close(env, verbose),
      1: lambda: reset(env, verbose),
      2: lambda: render(env, verbose),
      3: lambda: step(env, verbose),
      4: lambda: str_print(verbose)
    }.get(cmd, lambda: print('Error command:', cmd))
    if verbose and not cmd == 3 and not cmd == 2: print('cmd:', cmd, end=' ')
    excute()
    if not cmd: break

if __name__ == '__main__':
  import gym
  env = gym.make('MountainCar-v0')
  env = env.unwrapped
  #env = fakeenv()
  listen_cmd(env, False)
  #listen_cmd(env, True)

